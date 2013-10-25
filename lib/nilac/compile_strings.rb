def compile_strings(input_file_contents)

  def compile_small_q_syntax(input_file_contents)

    possible_syntax_usage = input_file_contents.reject { |element| !element.include?("%q") }

    possible_syntax_usage.each do |line|

      modified_line = line.dup

      line_split = line.split("+").collect { |element| element.lstrip.rstrip }

      line_split.each do |str|

        delimiter = str[str.index("%q")+2]

        string_extract = str[str.index("%q")..-1]

        delimiter = "}" if delimiter.eql?("{")

        delimiter = ")" if delimiter.eql?("(")

        delimiter = ">" if delimiter.eql?("<")

        if string_extract[-1].eql?(delimiter)

          input_file_contents[input_file_contents.index(modified_line)] = input_file_contents[input_file_contents.index(modified_line)].sub(string_extract, "'#{string_extract[3...-1]}'")

          modified_line = modified_line.sub(string_extract, "'#{string_extract[3...-1]}'")

        elsif delimiter.eql?(" ")

          input_file_contents[input_file_contents.index(modified_line)] = input_file_contents[input_file_contents.index(modified_line)].sub(string_extract, "'#{string_extract[3..-1]}'")

          modified_line = modified_line.sub(string_extract, "'#{string_extract[3..-1]}'")

        end

      end

    end

    return input_file_contents

  end

  def compile_big_q_syntax(input_file_contents)

    possible_syntax_usage = input_file_contents.reject { |element| !element.include?("%Q") }

    possible_syntax_usage.each do |line|

      modified_line = line.dup

      line_split = line.split("+").collect { |element| element.lstrip.rstrip }

      line_split.each do |str|

        delimiter = str[str.index("%Q")+2]

        string_extract = str[str.index("%Q")..-1]

        delimiter = "}" if delimiter.eql?("{")

        delimiter = ")" if delimiter.eql?("(")

        delimiter = ">" if delimiter.eql?("<")

        if string_extract[-1].eql?(delimiter)

          input_file_contents[input_file_contents.index(modified_line)] = input_file_contents[input_file_contents.index(modified_line)].sub(string_extract, "\"#{string_extract[3...-1]}\"")

          modified_line = modified_line.sub(string_extract, "\"#{string_extract[3...-1]}\"")

        elsif delimiter.eql?(" ")

          input_file_contents[input_file_contents.index(modified_line)] = input_file_contents[input_file_contents.index(modified_line)].sub(string_extract, "\"#{string_extract[3..-1]}\"")

          modified_line = modified_line.sub(string_extract, "\"#{string_extract[3..-1]}\"")

        end

      end

    end

    return input_file_contents

  end

  def compile_percentage_syntax(input_file_contents)

    possible_syntax_usage = input_file_contents.reject { |element| !element.include?("%") }

    possible_syntax_usage = possible_syntax_usage.reject { |element| element.index(/(\%(\W|\s)\w{1,})/).nil? }

    possible_syntax_usage.each do |line|

      modified_line = line.dup

      line_split = line.split("+").collect { |element| element.lstrip.rstrip }

      line_split.each do |str|

        delimiter = str[str.index("%")+1]

        string_extract = str[str.index("%")..-1]

        delimiter = "}" if delimiter.eql?("{")

        delimiter = ")" if delimiter.eql?("(")

        delimiter = ">" if delimiter.eql?("<")

        if string_extract[-1].eql?(delimiter)

          input_file_contents[input_file_contents.index(modified_line)] = input_file_contents[input_file_contents.index(modified_line)].sub(string_extract, "\"#{string_extract[2...-1]}\"")

          modified_line = modified_line.sub(string_extract, "\"#{string_extract[2...-1]}\"")

        elsif delimiter.eql?(" ")

          input_file_contents[input_file_contents.index(modified_line)] = input_file_contents[input_file_contents.index(modified_line)].sub(string_extract, "\"#{string_extract[2..-1]}\"")

          modified_line = modified_line.sub(string_extract, "\"#{string_extract[2..-1]}\"")

        end

      end

    end

    return input_file_contents

  end

  file_contents = compile_small_q_syntax(input_file_contents)

  file_contents = compile_big_q_syntax(file_contents)

  file_contents = compile_percentage_syntax(file_contents)

  return file_contents

end