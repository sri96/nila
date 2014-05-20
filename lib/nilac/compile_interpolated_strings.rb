require_relative 'find_all_matching_indices'
require_relative 'replace_strings'
require_relative 'extract_strings'
require_relative 'replace_comparison_operators'
  
  def compile_interpolated_strings(input_file_contents)

    def interpolation_variables(input_string)

      interpolation_vars = []

      modified_expressions = []

      input_string = input_string[2..-1]

      if replace_strings(input_string).include?(",")

        replaced_string = replace_strings(input_string)

        extracted_strings = extract_strings(input_string)

        semicolon_seperated_expressions = replaced_string.split(",")

        semicolon_seperated_expressions.each do |expr|

          matched_strings = expr.scan(/--repstring\d+/).to_a

          if matched_strings.empty?

            modified_expressions << expr

          else

            matched_strings.each do |str|

              junk,string_id = str.split("--repstring")

              modified_expressions << expr.sub("--repstring#{string_id}",extracted_strings[string_id.to_i])

            end

          end

        end

      end

      if modified_expressions.empty?

        modified_expressions << input_string

      end

      modified_expressions.each do |expr|

        if replace_strings(expr).include?("=")

          replaced_string = replace_strings(expr)

          string_split = replaced_string.split("=")

          interpolation_vars << string_split[0].strip

        end

      end

      return interpolation_vars

    end

    def replace_string_arrays(input_string)

      def extract(input_string, pattern_start, pattern_end)

        all_start_locations = find_all_matching_indices(input_string, pattern_start)

        all_end_locations = find_all_matching_indices(input_string, pattern_end)

        pattern = []

        all_start_locations.each_with_index do |location, index|

          pattern << input_string[location..all_end_locations[index]]

        end

        return pattern

      end

      if input_string.include?("%W")

        input_string = input_string.sub(extract(input_string,"%W{","}\n")[0],"--stringarray")

      end

      return input_string

    end

    interpolation_vars = []

    modified_file_contents = input_file_contents.dup

    single_quoted_strings = input_file_contents.reject { |element| !(element.count("'") >= 2) }

    single_quoted_string_array = []

    single_quote_counter = 0

    single_quoted_strings.each do |str|

      modified_string = str.dup

      while modified_string.include?("'")

        first_index = modified_string.index("'")

        string_extract = modified_string[first_index..modified_string.index("'", first_index+1)]

        single_quoted_string_array << string_extract

        modified_string = modified_string.sub(string_extract, "--single_quoted#{single_quote_counter}")

        single_quote_counter += 1

      end

      input_file_contents[input_file_contents.index(str)] = modified_string

    end

    input_file_contents.each_with_index do |line, index|

      if replace_string_arrays(line+"\n").include?("\#{")

        modified_line = line.dup

        possible_single_quoted_strings = modified_line.scan(/--single_quoted\d+/).to_a

        unless possible_single_quoted_strings.empty?

          possible_single_quoted_strings.each do |quoted_string|

            junk,string_id = quoted_string.split("--single_quoted")

            modified_line = modified_line.sub("--single_quoted#{string_id}",single_quoted_string_array[string_id.to_i])

          end

        end

        interpol_starting_loc = find_all_matching_indices(modified_line, "\#{") + [-1]

        interpolated_strings = []

        until interpol_starting_loc.empty?

          interpol_starting_loc[1] = -2 if interpol_starting_loc[1] == -1

          string_extract = modified_line[interpol_starting_loc[0]+1..interpol_starting_loc[1]+1]

          closed_curly_brace_index = find_all_matching_indices(string_extract, "}")

          index_counter = 0

          test_string = ""

          until closed_curly_brace_index.empty?

            test_string = string_extract[0..closed_curly_brace_index[0]]

            original_string = test_string.dup

            if test_string.include?("{")

              test_string = test_string.reverse.sub("{", "$#{index_counter}$").reverse

              test_string[-1] = "@#{index_counter}@"

            end

            string_extract = string_extract.sub(original_string, test_string)

            closed_curly_brace_index = find_all_matching_indices(string_extract, "}")

            index_counter += 1

          end

          string_extract = string_extract[0..string_extract.length-string_extract.reverse.index(/@\d@/)]

          interpolated_string = "\#{" + string_extract.split("@#{index_counter-1}@")[0].split("$#{index_counter-1}$")[1] + "}"

          to_be_replaced = interpolated_string.scan(/\$\d\$/)

          closing_brace_rep = interpolated_string.scan(/@\d@/)

          to_be_replaced.each_with_index do |rep, index|

            interpolated_string = interpolated_string.sub(rep, "{").sub(closing_brace_rep[index], "}")

          end

          interpolated_strings << interpolated_string

          modified_line = modified_line.sub(interpolated_string, "--interpolate")

          if find_all_matching_indices(modified_line, "\#{").empty?

            interpol_starting_loc = []

          else

            interpol_starting_loc = find_all_matching_indices(modified_line, "\#{") + [-1]

          end

        end

        interpolated_strings.each do |interpol|

          original_interpol = interpol.clone

          string_split = line.split(interpol)

          if string_split[1].eql?("\"\n")

            if replace_strings(interpol).include?(";")

              interpol = replace_strings(interpol)

              string_extracts = extract_strings(interpol)

              interpol = interpol.gsub(";",",")

              string_extracts.each do |str|

                matched_strings = str.scan(/--repstring/).to_a

                matched_strings.each do |matched_string|

                  junk,string_id = matched_string.split("--repstring")

                  interpol = interpol.sub("--repstring#{string_id}",string_extracts[string_id.to_i])

                end

              end

              interpol = replace_comparison_operators(interpol)

            end

            interpolation_variables(interpol)

            replacement_string = "\" + " + "(#{interpol[2...-1]})"

            modified_file_contents[index] = modified_file_contents[index].sub(original_interpol+"\"", replacement_string)

          elsif string_split[1].eql?("\")\n")

            if replace_strings(interpol).include?(";")

              interpol = replace_strings(interpol)

              string_extracts = extract_strings(interpol)

              interpol = interpol.gsub(";",",")

              string_extracts.each do |str|

                matched_strings = str.scan(/--repstring/).to_a

                matched_strings.each do |matched_string|

                  junk,string_id = matched_string.split("--repstring")

                  interpol = interpol.sub("--repstring#{string_id}",string_extracts[string_id.to_i])

                end

              end

              interpol = replace_comparison_operators(interpol)

            end

            interpolation_variables(interpol)

            replacement_string = "\" + " + "(#{interpol[2...-1]})"

            modified_file_contents[index] = modified_file_contents[index].sub(original_interpol + "\"", replacement_string)

          else

            if replace_strings(interpol).include?(";")

              interpol = replace_strings(interpol)

              string_extracts = extract_strings(interpol)

              interpol = interpol.gsub(";",",")

              string_extracts.each do |str|

                matched_strings = str.scan(/--repstring/).to_a

                matched_strings.each do |matched_string|

                  junk,string_id = matched_string.split("--repstring")

                  interpol = interpol.sub("--repstring#{string_id}",string_extracts[string_id.to_i])

                end

              end

              interpol = replace_comparison_operators(interpol)

            end

             interpolation_vars << interpolation_variables(interpol)

            replacement_string = "\"" + " + " + "(#{interpol[2...-1]})" + " + \""

            modified_file_contents[index] = modified_file_contents[index].sub(original_interpol, replacement_string)

          end

        end

      end

    end

    interpolation_vars = interpolation_vars.flatten.uniq

    return modified_file_contents, interpolation_vars

  end