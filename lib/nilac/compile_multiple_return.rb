def compile_multiple_return(input_array)

  def find_all_matching_indices(input_string, pattern)

    locations = []

    index = input_string.index(pattern)

    while index != nil

      locations << index

      index = input_string.index(pattern, index+1)


    end

    return locations


  end

  modified_input_array = input_array.dup

  return_statements = input_array.dup.reject { |element| !element.include? "return" }

  multiple_return_statements = return_statements.dup.reject { |element| !element.include? "," }

  modified_multiple_return_statements = multiple_return_statements.dup

  return_statement_index = []

  multiple_return_statements.each do |statement|

    location_array = modified_input_array.each_index.select { |index| modified_input_array[index] == statement }

    return_statement_index << location_array[0]

  end

  multiple_return_statements.each_with_index do |return_statement, index|

    replacement_counter = 0

    if return_statement.include? "\""

      starting_quotes = find_all_matching_indices(return_statement, "\"")

      for x in 0...(starting_quotes.length)/2

        quotes = return_statement[starting_quotes[x]..starting_quotes[x+1]]

        replacement_counter += 1

        modified_multiple_return_statements[index] = modified_multiple_return_statements[index].sub(quotes, "repstring#{1}")

        modified_input_array[return_statement_index[index]] = modified_multiple_return_statements[index].sub(quotes, "repstring#{1}")

      end

    end

  end

  modified_multiple_return_statements = modified_multiple_return_statements.reject { |element| !element.include? "," }

  return_statement_index = []

  modified_multiple_return_statements.each do |statement|

    location_array = modified_input_array.each_index.select { |index| modified_input_array[index] == statement }

    return_statement_index << location_array[0]

  end

  modified_multiple_return_statements.each_with_index do |return_statement, index|

    method_call_counter = 0

    if return_statement.include? "("

      open_paran_location = find_all_matching_indices(return_statement, "(")

      open_paran_location.each do |paran_index|

        method_call = return_statement[paran_index..return_statement.index(")", paran_index+1)]

        method_call_counter += 1

        modified_multiple_return_statements[index] = modified_multiple_return_statements[index].sub(method_call, "methodcall#{method_call_counter}")

        modified_input_array[return_statement_index[index]] = modified_multiple_return_statements[index].sub(method_call, "methodcall#{method_call_counter}")

      end

    end

  end

  modified_multiple_return_statements = modified_multiple_return_statements.reject { |element| !element.include?(",") }

  return_statement_index = []

  modified_multiple_return_statements.each do |statement|

    location_array = modified_input_array.each_index.select { |index| modified_input_array[index] == statement }

    return_statement_index << location_array[0]

  end

  return_statement_index.each do |index|

    original_statement = input_array[index]

    statement_split = original_statement.split("return ")

    replacement_split = "return [" + statement_split[1].rstrip + "]\n\n"

    input_array[index] = replacement_split

  end

  return input_array

end