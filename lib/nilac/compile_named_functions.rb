require_relative 'strToArray'
require_relative 'read_file_line_by_line'
require_relative 'paranthesis_compactor'
require_relative 'replace_strings'
require_relative 'rollblocks'

def compile_named_functions(input_file_contents, named_code_blocks, nested_functions, temporary_nila_file)

  #This method compiles all the named Nila functions. Below is an example of what is meant
  #by named/explicit function

  #def square(input_number)
  #
  #   input_number*input_number
  #
  #end

  #The above function will compile to

  #square = function(input_number) {
  #
  #  return input_number*input_number;
  #
  #};

  def is_parameterless?(input_function_block)

    if input_function_block[0].include?("(")

      false

    else

      true

    end

  end

  def lexical_scoped_variables(input_function_block)

    #This method will pickup and declare all the variables inside a function block. In future, this method will be
    #merged with the get variables method

    input_function_block = input_function_block.collect {|element| replace_strings(element)}

    controlregexp = /(if |Euuf |for |while |def |function |function\()/

    variables = []

    function_name, parameters = input_function_block[0].split("(")

    parameters = parameters.split(")")[0].split(",")

    parameters = parameters.collect { |element| element.strip }

    input_function_block.each do |line|

      if line.include? "=" and line.index(controlregexp).nil?

        current_line_split = line.strip.split("=")

        if current_line_split[0].include?("return")

          current_line_split[0] = current_line_split[0].sub("return","").strip

        end

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

  def remove_question_marks(input_file_contents, input_list, temporary_nila_file)

    joined_file_contents = input_file_contents.join

    input_list.each do |element|

      if element.include? "?"

        joined_file_contents = joined_file_contents.gsub(element, element[0...-1])

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

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

  def coffee_type_function(input_array)

    input_array = input_array.collect {|element| element.gsub("(function","&F*^u$#N)(&C")}

    function_name = input_array[0].split("function ")[1].split("(")[0].lstrip

    input_array[0] = "#{function_name} = function(" + input_array[0].split("function ")[1].split("(")[1].lstrip

    input_array = input_array.collect {|element| element.gsub("&F*^u$#N)(&C","(function")}

    return input_array

  end

  def compile_function(input_array, temporary_nila_file)

    modified_input_array = input_array.dup

    if is_parameterless?(modified_input_array)

      if modified_input_array[0].include?("--single")

        modified_input_array[0] = input_array[0].sub "def", "function"

        interim_string = modified_input_array[0].split("--single")

        modified_input_array[0] = interim_string[0].rstrip + "() {\n--single" + interim_string[1]


      elsif modified_input_array[0].include?("--multi")

        modified_input_array[0] = input_array[0].sub "def", "function"

        interim_string = modified_input_array[0].split("--multi")

        modified_input_array[0] = interim_string[0].rstrip + "() {\n--multi" + interim_string[1]

      else

        modified_input_array[0] = input_array[0].sub "def", "function"

        modified_input_array[0] = modified_input_array[0].rstrip + "() {\n"

      end

    else

      if modified_input_array[0].include?("--single")

        modified_input_array[0] = input_array[0].sub "def", "function"

        interim_string = modified_input_array[0].split("--single")

        modified_input_array[0] = interim_string[0].rstrip + " {\n--single" + interim_string[1]


      elsif modified_input_array[0].include?("--multi")

        modified_input_array[0] = input_array[0].sub "def", "function"

        interim_string = modified_input_array[0].split("--multi")

        modified_input_array[0] = interim_string[0].rstrip + " {\n--multi" + interim_string[1]

      else

        modified_input_array[0] = input_array[0].sub "def", "function"

        modified_input_array[0] = modified_input_array[0].rstrip + " {\n"

      end

    end

    modified_input_array[-1] = input_array[-1].sub "end", "};\n"

    modified_input_array = compile_parallel_assignment(modified_input_array, temporary_nila_file)

    modified_input_array = compile_multiple_ruby_func_calls(modified_input_array)

    modified_input_array = add_auto_return_statement(modified_input_array)

    modified_input_array = compile_multiple_return(modified_input_array)

    modified_input_array = coffee_type_function(modified_input_array)

    modified_input_array = compile_splats(modified_input_array)

    variables = lexical_scoped_variables(modified_input_array)

    if !variables.empty?

      variable_string = "\nvar " + variables.join(", ") + "\n"

      modified_input_array.insert(1, variable_string)

    end

    modified_input_array = remove_question_marks(modified_input_array, variables, temporary_nila_file)

    return modified_input_array

  end

  def extract_function_name(input_code_block)

    first_line = input_code_block[0]

    first_line_split = first_line.split(" ")

    if first_line_split[1].include?("(")

      function_name, parameters = first_line_split[1].split("(")

    else

      function_name = first_line_split[1]

    end

    return function_name

  end

  def compile_splats(input_function_block)

    def errorFree(function_params,optional_param)

      # This method checks for use cases in complex arguments where a default argument is used
      # after an optional argument. This will result in erroneous output. So this method will
      # stop it from happening.

      # Example:
      # def method_name(a,b,*c,d = 1,c,e)

      after_splat = function_params[function_params.index(optional_param)+1..-1]

      if after_splat.reject {|element| !element.include?("=")}.empty?

        true

      else

        raise "You cannot have a default argument after an optional argument!"

        false

      end

    end

    function_params = input_function_block[0].split("function(")[1].split(")")[0].split(",")

    unless function_params.reject{|element| !replace_strings(element).include?("*")}.empty?

      mod_function_params = function_params.reject {|element| replace_strings(element).include?("*")}

      opt_index = 0

      # If there are multiple optional params declared by mistake, only the first optional param is used.

      optional_param = function_params.reject {|element| !replace_strings(element).include?("*")}[0]

      if function_params.index(optional_param).eql?(function_params.length-1)

        mod_function_params.each_with_index do |param,index|

          input_function_block.insert(index+1,"#{param} = arguments[#{index}]\n\n")

          opt_index = index + 1

        end

        replacement_string = "#{optional_param.gsub("*","")} = []\n\n"

        replacement_string += "for (var i=#{opt_index};i<arguments.length;i++) {\n #{optional_param.gsub("*","")}.push(arguments[i]); \n}\n\n"

        input_function_block.insert(opt_index+1,replacement_string)

        input_function_block[0] = input_function_block[0].sub(function_params.join(","),"")

      else

        before_splat = function_params[0...function_params.index(optional_param)]

        after_splat = function_params[function_params.index(optional_param)+1..-1]

        cont_index = 0

        if errorFree(function_params,optional_param)

          before_splat.each_with_index do |param,index|

            input_function_block.insert(index+1,"#{param} = arguments[#{index}]\n\n")

            cont_index = index + 1

          end

          after_splat.each_with_index do |param,index|

            input_function_block.insert(cont_index+1,"#{param} = arguments[arguments.length-#{after_splat.length - index}]\n\n")

            cont_index = cont_index + 1

          end

          replacement_string = "#{optional_param.gsub("*","")} = []\n\n"

          replacement_string += "for (var i=#{function_params.index(optional_param)};i < arguments.length-#{after_splat.length};i++) {\n #{optional_param.gsub("*","")}.push(arguments[i]); \n}\n\n"

          input_function_block.insert(cont_index+1,replacement_string)

          input_function_block[0] = input_function_block[0].sub(function_params.join(","),"")

        end

      end

    end

    return strToArray(input_function_block.join)

  end

  def compile_multiple_ruby_func_calls(input_file_contents)

    def replace_complex_strings(input_string)

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

      input_string = input_string.gsub(/\((\w{0,},)*\w{0,}\)/,"--$k$")

      return input_string

    end

    function_calls = []

    replacement_calls = []

    function_map = %w{puts p print}

    javascript_regexp = /(if |for |while |\(function\(|= function\(|((=|:)\s+\{))/

    stringified_input = input_file_contents.collect {|element| replace_complex_strings(element)}

    function_map.each do |func|

      func_calls = input_file_contents.reject {|line| !(replace_strings(line).include?(func+"(") or replace_strings(line).include?(func+" ") and replace_strings(line).index(javascript_regexp) == nil)}

      unless func_calls.empty?

        modified_func_calls = func_calls.collect {|element| replace_complex_strings(element)}

        modified_func_calls = modified_func_calls.reject {|element| !element.include?(",")}

        modified_func_calls = modified_func_calls.reject {|element| !compact_paranthesis(element).include?(",")}

        call_collector = []

        modified_func_calls.each_with_index do |ele|

          call_collector << input_file_contents[stringified_input.index(ele)]

        end

        function_calls << modified_func_calls

        rep_calls = []

        call_collector.each do |fcall|

          multiple_call = fcall.split(func)[1].split(",")

          multiple_call = multiple_call.collect {|element| "\n#{func} " + element.strip + "\n\n"}

          rep_calls << multiple_call.join

        end

        replacement_calls << rep_calls

      end

    end

    replacement_calls = replacement_calls.flatten

    function_calls = function_calls.flatten

    function_calls.each_with_index do |fcall,index|

      input_file_contents[stringified_input.index(fcall)] = replacement_calls[index]

    end

    return strToArray(input_file_contents.join)

  end

  joined_file_contents = input_file_contents.join

  unless named_code_blocks.empty?

    codeblock_counter = 1

    function_names = []

    named_code_blocks.each do |codeblock|

      function_names[codeblock_counter-1] = []

      joined_file_contents = joined_file_contents.sub("--named_function[#{codeblock_counter}]\n", compile_function(codeblock, temporary_nila_file).join)

      codeblock_counter += 1

      function_names[codeblock_counter-2] << extract_function_name(codeblock)

      unless nested_functions.empty?

        current_nested_functions = nested_functions[codeblock_counter-2]

        current_nested_functions.each do |nested_function|

          function_names[codeblock_counter-2] << extract_function_name(nested_function)

          joined_file_contents = joined_file_contents.sub(nested_function.join, compile_function(nested_function, temporary_nila_file).join)

        end

      end

    end

  else

    function_names = []

  end

  file_id = open(temporary_nila_file, 'w')

  file_id.write(joined_file_contents)

  file_id.close()

  line_by_line_contents = compile_multiple_ruby_func_calls(read_file_line_by_line(temporary_nila_file))

  return line_by_line_contents, function_names

end