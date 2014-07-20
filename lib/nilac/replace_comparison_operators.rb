def replace_comparison_operators(input_string)

  element = input_string.gsub("equalequal","==")

  element = element.gsub("notequal", "!=")

  element = element.gsub("plusequal","+=")

  element = element.gsub("minusequal","-=")

  element = element.gsub("multiequal","*=")

  element = element.gsub("divequal","/=")

  element = element.gsub("modequal","%=")

  element = element.gsub("matchequal","=~")

  element = element.gsub("greatequal",">=")

  input_string = element.gsub("lessyequal","<=")

  return input_string

end