require_relative 'replace_strings'

def compile_unpacking_statements(input_file_contents)

  modified_file_contents = input_file_contents.clone

  possible_assignment_operators = input_file_contents.reject {|element| !replace_strings(element).include?("=") }

  possible_assignment_operators.each do |element|

    before,after = element.split("=")

    if replace_strings(before).include?("{") and replace_strings(before).include?("}")

      replacement_string = "_ref = #{after.strip}\n"

      internals = before.strip[1...-1].split(",")

      internals.each do |unpacked_var|

        replacement_string = replacement_string + "#{unpacked_var.strip} = _ref.#{unpacked_var.strip}\n"

      end

      modified_file_contents[modified_file_contents.index(element)] = replacement_string

    end

  end

  return modified_file_contents

end