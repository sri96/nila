require_relative 'find_all_matching_indices'
  
  def compile_interpolated_strings(input_file_contents)

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

    modified_file_contents = input_file_contents.dup

    single_quoted_strings = input_file_contents.reject { |element| !(element.count("'") >= 2) }

    single_quoted_strings.each do |str|

      modified_string = str.dup

      while modified_string.include?("'")

        first_index = modified_string.index("'")

        string_extract = modified_string[first_index..modified_string.index("'", first_index+1)]

        modified_string = modified_string.sub(string_extract, "--single_quoted")

      end

      input_file_contents[input_file_contents.index(str)] = modified_string

    end

    input_file_contents.each_with_index do |line, index|

      if replace_string_arrays(line+"\n").include?("\#{")

        modified_line = line.dup

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

          string_split = line.split(interpol)

          if string_split[1].eql?("\"\n")

            replacement_string = "\" + " + "(#{interpol[2...-1]})"

            modified_file_contents[index] = modified_file_contents[index].sub(interpol+"\"", replacement_string)

          elsif string_split[1].eql?("\")\n")

            replacement_string = "\" + " + "(#{interpol[2...-1]})"

            modified_file_contents[index] = modified_file_contents[index].sub(interpol + "\"", replacement_string)

          else

            replacement_string = "\"" + " + " + "(#{interpol[2...-1]})" + " + \""

            modified_file_contents[index] = modified_file_contents[index].sub(interpol, replacement_string)

          end

        end

      end

    end

    return modified_file_contents

  end