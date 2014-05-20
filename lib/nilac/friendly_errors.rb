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

  def check_comments(file_contents)

    def word_counter(input_string,word)

      string_split = input_string.split(word)

      return string_split.length-1

    end

    proceed = true

    joined_file_contents = file_contents.join

    joined_file_contents = replace_strings(joined_file_contents).gsub("_","")

    unless joined_file_contents.scan(/=\s+begin/).empty?

      puts "SyntaxWarning: Improper Whitespace\n\n"

      puts "I detected that you have used one or more spaces between '=' and 'begin' in your file. This is not allowed.\n\n"

      puts "But this is a very small mistake. So I am assuming you meant `=begin` and I will continue to compile.\n\n"

      puts "Please correct it before next time or else you will see this warning again!\n\n"

      puts "If you have any questions, please refer to the documentation at \n\nhttps://adhithyan15.github.io/nila/documentation.html#comments\n"

      joined_file_contents = joined_file_contents.gsub(/=\s+begin/,"=begin")

    end

    unless joined_file_contents.scan(/=\s+end/).empty?

      puts "SyntaxWarning: Improper Whitespace\n\n"

      puts "I detected that you have used one or more spaces between '=' and 'end' in your file. This is not allowed.\n\n"

      puts "But this is a very small mistake. So I am assuming you meant `=end` and I will continue to compile.\n\n"

      puts "Please correct it before next time or else you will see this warning again!\n\n"

      puts "If you have any questions, please refer to the documentation at \n\nhttps://adhithyan15.github.io/nila/documentation.html#comments\n"

      joined_file_contents = joined_file_contents.gsub(/=\s+end/,"=end")

    end

    block_comments = []

    while joined_file_contents.include?("=begin") or joined_file_contents.include?("=end")

      begin

        comment_start = joined_file_contents.index("=begin")

        comment_end = joined_file_contents.index("=end")

        block_comments << joined_file_contents[comment_start..comment_end]

        joined_file_contents[comment_start..comment_end] = ""

      rescue ArgumentError

        if comment_start == nil

          extracted_contents = joined_file_contents[0..comment_end].reverse

          line_number_match = extracted_contents.match(/>>>\d*<<</)

          line_number_match = line_number_match.to_a

          line_number_extract = line_number_match[0].split(">>>")[1].split("<<<")[0]

          puts "SyntaxError: Unexpected =end\n\n"

          puts "It seems like there is a problem with your multiline comment. I am checking where that happened! Give me a few seconds..... \n\n"

          puts "In line number #{line_number_extract}, I detected an `=end` statement. But no matching `=begin` statement was found! Please fix it immediately!\n\n"

          puts "I cannot proceed with out it!\n\n"

          puts "If you have any questions, please refer to the documentation at \n\nhttps://adhithyan15.github.io/nila/documentation.html#comments\n"

          exit

        end

        if comment_end == nil

          extracted_contents = joined_file_contents[0..comment_start].reverse

          line_number_match = extracted_contents.match(/>>>\d*<<</)

          line_number_match = line_number_match.to_a

          line_number_extract = line_number_match[0].split(">>>")[1].split("<<<")[0]

          puts "SyntaxError: Unexpected =begin\n\n"

          puts "It seems like there is a problem with your multiline comment. I am checking where that happened! Give me a few seconds..... \n\n"

          puts "In line number #{line_number_extract}, I detected a `=begin` statement. But no matching `=end` statement was found! Please fix it immediately!\n\n"

          puts "I cannot proceed with out it!\n\n"

          puts "If you have any questions, please refer to the documentation at \n\nhttps://adhithyan15.github.io/nila/documentation.html#comments\n"

          exit

        end

      end

    end

    return proceed

  end

  def check_heredoc_syntax(input_file_contents)

    proceed = true



  end

end