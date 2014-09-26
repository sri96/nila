require_relative 'replace_strings'
require_relative 'compile_multiple_return'
require_relative 'strToArray'
require_relative 'lexical_scoped_function_variables'
require_relative 'add_auto_return_statement'

def compile_lambdas(input_file_contents,temporary_nila_file)

  def compile_empty_lambdas(input_file_contents)

    modified_file_contents = input_file_contents.clone

    input_file_contents.each do |element|

      if replace_strings(element).index(/lambda\s*\{\}/)

        modified_file_contents[modified_file_contents.index(element)] = element.gsub()

      end

    end

  end

  def compile_single_line_lambda(input_block,parameterless = false)

    # This method compiles a single lambda into a Javascript function expression

    if parameterless

      if input_block[0] = "{" and input_block[-1] = "}"

        block_contents = input_block[1...-1]

      else

        block_contents = input_block[3...-1]

      end

      compiled_lambda = "function() {\n\n  #{block_contents.strip} \n\n}"

    else

      block_parameters, block_contents = input_block[1...-1].split("|",2)[1].split("|",2)

      compiled_lambda = "function(#{block_parameters.lstrip.rstrip}) {\n\n  #{block_contents.strip} \n\n}"

    end

    return compiled_lambda

  end

  def find_lambda_name(input_block)

    first_line = input_block[0]

    var_name = "varrrr"

    if first_line.include?("=")

      var_name,junk = first_line.split("=")

      var_name = var_name.strip

    end

    return var_name

  end

  input_file_contents = input_file_contents.collect {|element| (replace_strings(element).include?(" -> ") ? element.gsub(" -> "," lambda ") : element)}

  input_file_contents = input_file_contents.collect {|element| element.gsub("document","decccccumennt")}

  input_file_contents = input_file_contents.collect {|element| element.gsub("append","appand").gsub(" do"," do ").gsub("do "," do ")}

  compile_empty_lambdas(input_file_contents)

  possible_lambdas = input_file_contents.reject {|line| !replace_strings(line).include?("lambda")}

  possible_lambdas = possible_lambdas.reject {|line| line.index(/\s*do\s*/) == nil}

  lambda_names = []

  unless possible_lambdas.empty?

    possible_lambdas.each do |starting_line|

      index_counter = starting_counter = input_file_contents.index(starting_line)

      line = starting_line

      until line.strip.eql?("end") or line.strip.eql?("end)")

        index_counter += 1

        line = input_file_contents[index_counter]

      end

      loop_extract = input_file_contents[starting_counter..index_counter]

      var_name,block = loop_extract.join.split(/\s*do\s+/)

      var_name = var_name.split(/\s*=\s*lambda/)[0].strip

      block = block.split("end")[0]

      replacement_string = "#{var_name} = lambda blockky {#{block.strip}}_!"

      input_file_contents[starting_counter..index_counter] = replacement_string

    end

  end

  possible_lambdas = input_file_contents.reject{ |element| element.index(/lambda\s*(blockky)?\s*/) == nil}

  possible_lambdas = possible_lambdas.reject {|element| !element.include?("{") and !element.include?("}")}

  modified_file_contents = input_file_contents.clone

  unless possible_lambdas.empty?

    original_loops = possible_lambdas.clone

    possible_lambdas = possible_lambdas.collect {|element| element.gsub(/lambda\s*\{/,"lambda !_{")}

    possible_lambdas.each_with_index do |loop,index|

      original_loop = original_loops[index]

      string_counter = 1

      extracted_string = []

      while loop.include?("\"")

        string_extract = loop[loop.index("\"")..loop.index("\"",loop.index("\"")+1)]

        extracted_string << string_extract

        loop = loop.sub(string_extract,"--repstring#{string_counter}")

        string_counter += 1

      end

      lambda_extract = loop[loop.index("{")..loop.index("}_!")] if loop.include?("}_!")

      lambda_extract = loop[loop.index("!_{")..loop.index("}")] if loop.include?("!_{")

      compiled_lambda = ""

      if lambda_extract.count("|") == 2

        compiled_lambda = compile_single_line_lambda(lambda_extract)

        extracted_string.each_with_index do |string,index|

          compiled_lambda = compiled_lambda.sub("--repstring#{index+1}",string)

        end

      else

        compiled_lambda = compile_single_line_lambda(lambda_extract,true)

        extracted_string.each_with_index do |string,index|

          compiled_lambda = compiled_lambda.sub("--repstring#{index+1}",string)

        end

      end

      original_loop = original_loop.gsub("!_{","{")

      replacement_string = loop.split(lambda_extract)[0].split("lambda")[0] + compiled_lambda

      replacement_array = strToArray(replacement_string)

      replacement_array = compile_multiple_return(replacement_array)

      replacement_array = add_auto_return_statement(replacement_array)

      variables = lexical_scoped_variables(replacement_array)

      if !variables.empty?

        variable_string = "\nvar " + variables.join(", ") + "\n"

        replacement_array.insert(1, variable_string)

      end

      lambda_name = find_lambda_name(replacement_array)

      unless lambda_name.eql?("varrrr")

        lambda_names << lambda_name

      end

      replacement_array[1...-1] = replacement_array[1...-1].collect {|element| "#iggggnnnore #{element}"}

      replacement_array[0] = replacement_array[0].sub("function","lambdef").sub("{\n","%--%\n")

      replacement_array[-1] = replacement_array[-1].sub("}","\n-%%-")

      replacement_string = replacement_array.join

      replacement_string = replacement_string[-1].eql?(";") ? replacement_string : (replacement_string + ";")

      modified_file_contents[input_file_contents.index(original_loop)] = (replacement_string + "\n\n")

    end

  end

  modified_file_contents = modified_file_contents.collect {|element| element.gsub("appand","append")}

  modified_file_contents = modified_file_contents.collect {|element| element.gsub("decccccumennt","document")}

  file_id = open(temporary_nila_file, 'w')

  file_id.write(modified_file_contents.join)

  file_id.close()

  line_by_line_contents = read_file_line_by_line(temporary_nila_file)

  return line_by_line_contents,lambda_names

end