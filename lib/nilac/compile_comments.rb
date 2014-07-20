require_relative 'read_file_line_by_line'
require_relative 'strToArray'
  
  def compile_comments(input_file_contents, comments, temporary_nila_file)

    #This method converts Nila comments into pure Javascript comments. This method
    #handles both single line and multiline comments.

    file_contents_as_string = input_file_contents.join

    single_line_comments = comments[0]

    multiline_comments = comments[1]

    single_line_comment_counter = 1

    multi_line_comment_counter = 1

    ignorable_keywords = [/if/, /while/, /function/]

    dummy_replacement_words = ["eeuuff", "whaalesskkey", "conffoolotion"]

    for x in 0...single_line_comments.length

      current_singleline_comment = "--single_line_comment[#{single_line_comment_counter}]"

      replacement_singleline_string = single_line_comments[x].sub("#", "//")

      ignorable_keywords.each_with_index do |keyword, index|

        if replacement_singleline_string.index(keyword) != nil

          replacement_singleline_string = replacement_singleline_string.sub(keyword.inspect[1...-1], dummy_replacement_words[index])

        end

      end

      file_contents_as_string = file_contents_as_string.sub(current_singleline_comment, replacement_singleline_string)

      single_line_comment_counter += 1


    end

    for y in 0...multiline_comments.length

      current_multiline_comment = "--multiline_comment[#{multi_line_comment_counter}]"

      replacement_multiline_string = multiline_comments[y].sub("=begin", "/*\n")

      replacement_multiline_string = replacement_multiline_string.sub("=end", "\n*/")

      replacement_array = strToArray(replacement_multiline_string)

      replacement_array[2...-2] = replacement_array[2...-2].collect {|element| "  " + element}

      replacement_array = [replacement_array[0]] + replacement_array[1...-1].reject {|element| element.strip.eql?("")} + [replacement_array[-1]]

      replacement_multiline_string = replacement_array.join

      ignorable_keywords.each_with_index do |keyword, index|

        if replacement_multiline_string.index(keyword) != nil

          replacement_multiline_string = replacement_multiline_string.sub(keyword.inspect[1...-1], dummy_replacement_words[index])

        end

      end

      file_contents_as_string = file_contents_as_string.sub(current_multiline_comment, replacement_multiline_string)

      multi_line_comment_counter += 1

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(file_contents_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    line_by_line_contents

  end