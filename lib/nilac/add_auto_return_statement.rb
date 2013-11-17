def add_auto_return_statement(input_array)

  joined_array = input_array.join

  reversed_input_array = input_array.reverse

  if !joined_array.include?("return ")

    rejected_array = reversed_input_array.reject { |content| content.lstrip.eql?("") }

    rejected_array = rejected_array.reject {|content| content.strip.eql?("")}

    rejected_array = rejected_array[1..-1]

    unless rejected_array[0].strip.eql?("}") or rejected_array[0].strip.eql?("})")

      if !rejected_array[0].strip.eql?("end") and !rejected_array[0].strip.include?("--single_line_comment")

        last_statement = rejected_array[0]

        replacement_string = "return #{last_statement.lstrip}"

        input_array[input_array.index(last_statement)] = replacement_string

      end

    end

  end

  return input_array

end