def split_semicolon_seperated_expressions(input_file_contents)

  modified_file_contents = input_file_contents.dup

  input_file_contents.each_with_index do |line, index|

    if line.include?("\"")

      first_index = line.index("\"")

      modified_line = line.sub(line[first_index..line.index("\"", first_index+1)], "--string")

    elsif line.include?("'")

      first_index = line.index("'")

      modified_line = line.sub(line[first_index..line.index("'", first_index+1)], "--string")

    else

      modified_line = line

    end

    if modified_line.include?(";")

      replacement_line = modified_file_contents[index]

      replacement_line = replacement_line.split(";").join("\n\n") + "\n"

      modified_file_contents[index] = replacement_line

    end

  end

  return modified_file_contents

end