def compact_square_brackets(input_string)

  string_extract = input_string.reverse

  paranthesis_extract = [""]

  two_paranthesis = ""

  open_paran_index = nil

  offset_value = nil

  while string_extract.include?("[")

    open_paran_index = string_extract.index("[")

    test_extract = string_extract[0..open_paran_index].reverse

    two_paranthesis = test_extract[0..test_extract.index("]")]

    previous_value = paranthesis_extract[-1]

    if previous_value.length > two_paranthesis.length-(two_paranthesis.count("$@"))/2

      offset_value = previous_value

    end

    paranthesis_extract << two_paranthesis.sub("$@"*previous_value.length,previous_value)

    string_extract = string_extract.sub(two_paranthesis.reverse,"@$"*paranthesis_extract[-1].length)

  end

  return string_extract.reverse

end