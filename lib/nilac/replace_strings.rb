# This is the simplest and most important method on the whole Nilac source code. This protects user written
# strings from being overwritten during the compilation

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

  if input_string.count("\"") % 2 == 0

    while input_string.include?("\"")

    string_extract = input_string[input_string.index("\"")..input_string.index("\"",input_string.index("\"")+1)]

    input_string = input_string.sub(string_extract,"--repstring#{string_counter}")

    string_counter += 1

    end

  end

  if input_string.count("'") % 2 == 0

    while input_string.include?("'")

      string_extract = input_string[input_string.index("'")..input_string.index("'",input_string.index("'")+1)]

      input_string = input_string.sub(string_extract,"--repstring#{string_counter}")

      string_counter += 1

    end

  end

  return input_string

end
