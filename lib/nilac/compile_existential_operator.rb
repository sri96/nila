require_relative 'replace_strings'

def compile_existential_operators(input_file_contents)

  # This method compiles Nila's existential operator.
  #
  # Example:
  #
  # input_args[0].nil?
  #
  # The above line should compile to
  #
  # typeof input_args[0] === undefined && input_args[0] === nil

  modified_contents = input_file_contents.collect {|element| replace_strings(element)}

  possible_existential_calls = modified_contents.reject {|element| !element.include?(".nil")}

  split_regexp = /((if|while) \((!\()?)/

  second_split_regexp = /(&&|\|\|)/

  possible_existential_calls.each do |statement|

    reconstructed_statement = input_file_contents[modified_contents.index(statement)]

    counter = 0

    while reconstructed_statement.include?(".nil")

      before,after = reconstructed_statement.split(".nil",2)

      if counter == 0

        split_data = before.split(split_regexp)

        before2 = split_data[1]

        if before2.eql?("if (") or before2.eql?("while (")

          usage = split_data[3]

        elsif before2.eql?("if (!(") or before2.eql?("while (!(")

          usage = split_data[4]

        end

        replacement_string = "(typeof #{usage} === \"undefined\" &|&| #{usage} === null)"

        reconstructed_statement = before.split(before2)[0] + before2 + replacement_string + after

      elsif counter > 0

        split_data = before.split(second_split_regexp)

        before2 = split_data[0]

        operator = split_data[1]

        operator = " &|&| " if operator.strip.eql?("&&")

        operator = " |$|$ " if operator.strip.eql?("||")

        usage = split_data[2]

        replacement_string = "(typeof #{usage} === \"undefined\" &|&| #{usage} === null)"

        reconstructed_statement = before2 + operator + replacement_string + after

      end

      counter += 1

    end

    reconstructed_statement = reconstructed_statement.gsub("&|&|","&&").gsub("|$|$","&&")

    input_file_contents[modified_contents.index(statement)] = reconstructed_statement

  end

  return input_file_contents

end

def compile_undefined_operator(input_file_contents)

  # This method compiles Nila's .undefined? method to native Javascript

  # Example:
  #
  # input_args[0].undefined?
  #
  # The above line should compile to
  #
  # typeof input_args[0] === "undefined"

  modified_contents = input_file_contents.collect {|element| replace_strings(element)}

  possible_existential_calls = modified_contents.reject {|element| !element.include?(".undefined")}

  split_regexp = /((if|while) \((!\()?)/

  second_split_regexp = /(&&|\|\|)/

  possible_existential_calls.each do |statement|

    reconstructed_statement = input_file_contents[modified_contents.index(statement)]

    counter = 0

    while reconstructed_statement.include?(".undefined")

      before,after = reconstructed_statement.split(".undefined",2)

      if counter == 0

        split_data = before.split(split_regexp)

        before2 = split_data[1]

        if before2.eql?("if (") or before2.eql?("while (")

          usage = split_data[3]

        elsif before2.eql?("if (!(") or before2.eql?("while (!(")

          usage = split_data[4]

        end

        replacement_string = "(typeof #{usage} === \"undefined\")"

        reconstructed_statement = before.split(before2)[0] + before2 + replacement_string + after

      elsif counter > 0

        split_data = before.split(second_split_regexp)

        before2 = split_data[0]

        operator = split_data[1]

        operator = " &|&| " if operator.strip.eql?("&&")

        operator = " |$|$ " if operator.strip.eql?("||")

        usage = split_data[2]

        replacement_string = "(typeof #{usage} === \"undefined\")"

        reconstructed_statement = before2 + operator + replacement_string + after

      end

      counter += 1

    end

    reconstructed_statement = reconstructed_statement.gsub("&|&|","&&").gsub("|$|$","&&")

    input_file_contents[modified_contents.index(statement)] = reconstructed_statement

  end

  return input_file_contents

end