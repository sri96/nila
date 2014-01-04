# Nila currently lacks good error messages. So this is an attempt to fix the problem. This module will define a standard
# set of errors and debugging features that will be utilized by the Nila compiler.

require_relative 'replace_strings'
require_relative 'rollblocks'

module FriendlyErrors

  def combine_strings(input_list)

    if input_list.length == 1

      return input_list.join

    elsif input_list.length > 1

      last_element = input_list.pop

      statement = input_list.join(", ") + " and #{last_element}"

      return statement

    end

  end

  def file_exist?(file_name)

    message = ""

    proceed_to_next = true

    if File.exist?(file_name)

      unless file_name.include?(".nila")

        message = "Hey! I currently don't have the capacity to compile files other than Nila files. I am sorry!\n\n"

        proceed_to_next = false

      end

    else

      message = "Hey! I cannot find the file specified\n\nCan you check to see if the file exists or accessible?\n\n"

      proceed_to_next = false

    end

    return message, proceed_to_next

  end

  def proper_parsable_statement(file_contents)

    match_expr = [/_(\w{3})_/,/__(\w{3})/,/_(\w{3})_/]

    almost_match = /__(\w{3})__/

    correct_expr = /__END__/

    message = ""

    proceed_to_next = true

    modified_file_contents = file_contents.clone

    possible_parse_end_statements =  file_contents.reject {|element| !replace_strings(element).index(almost_match)}

    parse_end_statements = possible_parse_end_statements.reject {|element| !element.index(correct_expr)}

    if possible_parse_end_statements.length > 1

      line_numbers = []

      possible_parse_end_statements.each do |statement|

        line_numbers << modified_file_contents.index(statement) + 1

        modified_file_contents[line_numbers[-1]-1] = "--enddd_statement"

      end

      message = "Hey! I noticed that you used __END__ statement #{line_numbers.length} times in your file on line numbers #{combine_strings(line_numbers)}.\n\n"

      message += "Unfortunately, this is not allowed. You can only use it once in a file.\n\nPlease remove one of those statements\n\nIf you are confused about the usage of __END__,please refer to the \ndocumentation at http://adhithyan15.github.io/nilac\n\n"

      proceed_to_next = false

    end

  end

end