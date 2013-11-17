def lexical_scoped_variables(input_function_block)

  #This method will pickup and declare all the variables inside a function block. In future, this method will be
  #merged with the get variables method

  def replace_strings(input_string)

    element = input_string.gsub("==", "equalequal")

    element = element.gsub("!=", "notequal")

    element = element.gsub("+=", "plusequal")

    element = element.gsub("-=", "minusequal")

    element = element.gsub("*=", "multiequal")

    element = element.gsub("/=", "divequal")

    element = element.gsub("%=", "modequal")

    element = element.gsub("=~", "matchequal")

    element = element.gsub(">=", "greatequal")

    input_string = element.gsub("<=", "lessyequal")

    string_counter = 0

    while input_string.include?("\"")

      string_extract = input_string[input_string.index("\"")..input_string.index("\"",input_string.index("\"")+1)]

      input_string = input_string.sub(string_extract,"--repstring#{string_counter}")

      string_counter += 1

    end

    while input_string.include?("'")

      string_extract = input_string[input_string.index("'")..input_string.index("'",input_string.index("'")+1)]

      input_string = input_string.sub(string_extract,"--repstring#{string_counter}")

      string_counter += 1

    end

    return input_string

  end

  input_function_block = input_function_block.collect {|element| replace_strings(element)}

  controlregexp = /(if |Euuf |for |while |def |function |function\()/

  variables = []

  function_name, parameters = input_function_block[0].split("(")

  parameters = parameters.split(")")[0].split(",")

  parameters = parameters.collect { |element| element.strip }

  input_function_block.each do |line|

    if line.include? "=" and line.index(controlregexp).nil?

      current_line_split = line.strip.split("=")

      variables << current_line_split[0].rstrip

    end

  end

  parameters.each do |param|

    if variables.include?(param)

      variables.delete(param)

    end

  end

  if variables.empty?

    return []

  else

    return variables.uniq.sort

  end

end