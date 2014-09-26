require_relative 'replace_strings'
require_relative 'read_file_line_by_line'
require_relative 'paranthesis_compactor'
require_relative 'extract_paranthesis_contents'

  def get_variables(input_file_contents, temporary_nila_file, *loop_variables)

    variables = []

    input_file_contents = input_file_contents.collect { |element| element.gsub("==", "equalequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("!=", "notequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("+=", "plusequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("-=", "minusequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("*=", "multiequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("/=", "divequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("%=", "modequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("=~", "matchequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub(">=", "greatequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("<=", "lessyequal") }

    modified_file_contents = input_file_contents.clone

    input_file_contents = input_file_contents.collect {|element| replace_strings(element)}

    javascript_regexp = /(if |while |for |\|\|=|&&=)/

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      original_row = current_row.clone

      if current_row.include?("=") and current_row.index(javascript_regexp) == nil and !current_row.include?("#iggggnnnore")

        if current_row.index(/,function\(/)

          current_row = current_row.strip + "$@#)\n\n"

        end

        if compact_paranthesis(current_row).include?("=")

          current_row = current_row.gsub("$@#)\n\n","\n")

          current_row = current_row.rstrip + "\n"

          if current_row.count("=") > 1

            if compact_paranthesis(current_row).count("=") > 1

              current_row_split = current_row.split("=")

              current_row_split[0...-1].each do |split|

                variables << split.strip

              end

            else

              paranthesis_contents = extract_paranthesis_contents(current_row)

              paranthesis_contents = paranthesis_contents.reject {|element| !replace_strings(element).include?("=")}

              paranthesis_contents.each do |element|

                string_extract = element.strip[1...-1]

                variables << string_extract.split("=").collect {|element| element.strip}[0]

              end

              if compact_paranthesis(current_row).include?("=")

                variables << current_row.split("=",2).collect {|element| element.strip}[0]

              end

            end

          else

            current_row_split = current_row.split("=")

            current_row_split = current_row_split.collect {|element| element.strip}

            if current_row_split[0].include?("[") or current_row_split[0].include?("(")

              current_row_split[0] = current_row_split[0][0...current_row_split[0].index("[")]

            end

            current_row_split[0] = current_row_split[0].split(".",2)[0].strip if current_row_split[0].include?(".")

            if current_row_split[0].include?(" ")

              variable_name = current_row_split[0].split

              variable_name = variable_name.join("_")

              modified_file_contents[modified_file_contents.index(original_row)] = modified_file_contents[modified_file_contents.index(original_row)].gsub(current_row_split[0],variable_name)

            else

              variable_name = current_row_split[0]

            end

          end

          variables << variable_name

        end

      end

    end

    file_contents_as_string = modified_file_contents.join

    file_id = open(temporary_nila_file, 'w')

    file_id.write(file_contents_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    test_contents = line_by_line_contents.collect {|element| replace_strings(element)}

    for_loop_variables = []

    for_loop_statements = test_contents.reject {|line| !line.include?("for")}
      
    for_loop_statements = for_loop_statements.reject {|line| line.include?("forEach")}

    for_loop_statements.each do |statement|

      varis = statement.split("for (")[1].split(";",2)[0].split(",")

      for_loop_variables << varis.collect {|vari| vari.strip.split("=")[0].strip}

      for_loop_variables = for_loop_variables.flatten

    end

    variables += loop_variables

    variables += for_loop_variables

    variables = variables.flatten

    #remove_properties(variables)

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("plusequal", "+=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("minusequal", "-=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("multiequal", "*=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("divequal", "/=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("modequal", "%=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("equalequal", "==") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("notequal", "!=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("matchequal", "=~") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("greatequal", ">=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("lessyequal", "<=") }

    return variables.uniq.compact, line_by_line_contents

  end