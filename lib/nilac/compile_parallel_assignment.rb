require_relative 'replace_strings'
require_relative 'read_file_line_by_line'
require_relative 'paranthesis_compactor'
  
  def compile_parallel_assignment(input_file_contents, temporary_nila_file)

    def arrayify_right_side(input_string)

      modified_input_string = input_string.dup

      input_string = replace_strings(input_string)

      javascript_regexp = /(if |while |for |function |function\()/

      if input_string.include?("=") and input_string.index(javascript_regexp) == nil and input_string.strip[0..3] != "_ref" and !input_string.split("=")[1].include?("[")

        right_side = input_string.split("=")[1]

        if compact_paranthesis(right_side).include?(",")

          splits = right_side.split(",")

          replacement_string = []

          splits.each do |str|

            unless str.include?(")") and !str.include?("(")

              replacement_string << str

            else

              replacement_string[-1] = replacement_string[-1]+ "," +str

            end

          end

          replacement_string = " [#{replacement_string.join(",").strip}]\n"

          modified_input_string = modified_input_string.sub(right_side,replacement_string)

        end

      end

      return modified_input_string

    end

    input_file_contents = input_file_contents.collect {|element| arrayify_right_side(element)}

    possible_variable_lines = input_file_contents.clone.reject { |element| !element.include? "=" }

    possible_parallel_assignment = possible_variable_lines.reject { |element| !element.split("=")[0].include? "," }

    parallel_assignment_index = []

    possible_parallel_assignment.each do |statement|

      location_array = input_file_contents.each_index.select { |index| input_file_contents[index] == statement }

      parallel_assignment_index << location_array[0]

    end

    modified_file_contents = input_file_contents.dup

    parallel_assignment_counter = 1

    possible_parallel_assignment.each_with_index do |line, index|

      line_split = line.split(" = ")

      right_side_variables = line_split[0].split(",")

      replacement_string = "_ref#{parallel_assignment_counter} = #{line_split[1]}\n\n"

      variable_string = ""

      right_side_variables.each_with_index do |variable, var_index|

        variable_string = variable_string + variable.rstrip + " = _ref#{parallel_assignment_counter}[#{var_index}]\n\n"

      end

      replacement_string = replacement_string + variable_string

      modified_file_contents[parallel_assignment_index[index]] = replacement_string

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(modified_file_contents.join)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end