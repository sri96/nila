require_relative 'read_file_line_by_line'
  
  def compile_heredocs(input_file_contents, temporary_nila_file)

    joined_file_contents = input_file_contents.join

    possible_heredocs = input_file_contents.reject { |element| !element.include?("<<-") }

    possible_heredocs = possible_heredocs.collect { |element| element.match(/<<-(.*|\w*)/).to_a[0] }

    possible_heredocs.each do |heredoc|

      delimiter = heredoc[3..-1]

      quote = 2

      if delimiter.include?("'")

        quote = 1

      end

      delimiter = delimiter.gsub("\"", "") if quote == 2

      delimiter = delimiter.gsub("'", "") if quote == 1

      string_split = joined_file_contents.split(heredoc, 2)

      string_extract = string_split[1]

      heredoc_extract = string_extract[0...string_extract.index(delimiter)]

      replacement_string = ""

      if quote == 1

        replacement_string = "'#{heredoc_extract.delete("\"")}'".lstrip.inspect

        replacement_string = replacement_string[1..-2]

      elsif quote == 2

        replacement_string = heredoc_extract.lstrip.inspect

      end

      replacement_string = replacement_string.gsub("\\#","#")

      joined_file_contents = joined_file_contents.sub(heredoc + heredoc_extract + delimiter, replacement_string)

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents


  end