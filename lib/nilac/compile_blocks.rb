require_relative 'read_file_line_by_line'
require_relative 'strToArray'
require_relative 'lexical_scoped_function_variables'
require_relative 'rollblocks'
require_relative 'replace_strings'
  
  def compile_blocks(input_file_contents,temporary_nila_file)

    def compile_one_line_blocks(input_block)

      block_parameters, block_contents = input_block[1...-1].split("|",2)[1].split("|",2)

      if block_parameters.include?("err") and !block_contents.include?("err")

        block_contents = "if (err) {\n puts err \n}\n" + block_contents

      end

      compiled_block = "function(#{block_parameters.lstrip.rstrip}) {\n\n  #{block_contents.strip} \n\n}"

      return compiled_block

    end

    input_file_contents = input_file_contents.collect {|element| element.gsub("append","appand")}

    input_file_contents = input_file_contents.collect {|element| element.gsub(" do"," do ").gsub("do "," do ")}

    modified_file_contents = input_file_contents.clone.collect {|element| element.gsub("end","end"+"   "*rand(1..10))}

    possible_blocks = modified_file_contents.clone.reject {|line| !line.include?(" do ")}

    extract_expr = /(if |Euuf |while |for |def | do )/

    starting_locations = []

    input_file_contents.each_with_index do |line, index|

      if replace_strings(line).index(extract_expr) != nil

        starting_locations << index

      end

    end

    starting_locations = [0,starting_locations,-1].flatten.uniq

    remaining_contents, extracted_blocks = extract_blocks(starting_locations,modified_file_contents,["if","for","while","def and do"])

    possible_blocks = extracted_blocks.reject {|element| !element[0].index(/( do )/)}

    replaced_blocks = []

    unless possible_blocks.empty?

      possible_blocks.each do |element|

        starting_counter = modified_file_contents.index(element[0])

        end_counter = modified_file_contents.index(element[-1])

        loop_extract = input_file_contents[starting_counter..end_counter]

        loop_condition,function_parameters= loop_extract[0].split(" do ")

        block = [function_parameters] + loop_extract[1...-1]

        replacement_string = "#{loop_condition.rstrip} blockky \n{#{block.join.strip}\n}_!"

        replaced_blocks << replacement_string

        input_file_contents[starting_counter..end_counter] = replacement_string

        modified_file_contents[starting_counter..end_counter] = replacement_string

      end

    end

    original_blocks = replaced_blocks.clone

    possible_blocks = replaced_blocks.clone

    joined_file_contents = input_file_contents.clone.join

    unless possible_blocks.empty?

      possible_blocks.each_with_index do |loop,index|

        original_loop = original_blocks[index]

        string_counter = 1

        extracted_string = []

        while loop.include?("\"")

          string_extract = loop[loop.index("\"")..loop.index("\"",loop.index("\"")+1)]

          extracted_string << string_extract

          loop = loop.sub(string_extract,"--repstring#{string_counter}")

          string_counter += 1

        end

        block_extract = strToArray(loop)[1..-1].join[0...-2]

        compiled_block = ""

        if block_extract.count("|") == 2

          compiled_block = compile_one_line_blocks(block_extract)

          extracted_string.each_with_index do |string,index|

            compiled_block = compiled_block.sub("--repstring#{index+1}",string)

          end

        else

          compiled_block = "function() {\n\n" + block_extract[1...-1].lstrip.rstrip + "\n\n}"

          extracted_string.each_with_index do |string,index|

            compiled_block = compiled_block.sub("--repstring#{index+1}",string)

          end

        end

        caller_func = loop.split(" blockky ")[0]

        unless caller_func.strip[-1] == ","

          replacement_string = "#{caller_func.rstrip}(#{compiled_block.lstrip})"

        else

          caller_func_split = caller_func.split("(") if caller_func.include?("(")

          if caller_func.include?("=")

            first_split = caller_func.split("=")

            caller_func_split = first_split[1].split(" ",2)

            caller_func_split[0] = first_split[0].strip + " = " +  caller_func_split[0]

          else

            caller_func_split = caller_func.split(" ",2) if caller_func.include?(" ")

          end

          replacement_string = "#{caller_func_split[0]}(#{caller_func_split[1].strip + compiled_block.lstrip})"

        end

        replacement_array = strToArray(replacement_string)

        replacement_array[-1] = replacement_array[-1] + "\n\n"

        replacement_array << "\n\n"

        variables = lexical_scoped_variables(replacement_array)

        if !variables.empty?

          variable_string = "\nvar " + variables.join(", ") + "\n"

          replacement_array.insert(1, variable_string)

        end

        replacement_array[1...-1] = replacement_array[1...-1].collect {|element| "#iggggnnnore #{element}"}

        starting_counter = joined_file_contents.index(original_loop)

        end_counter = joined_file_contents.index(original_loop)+original_loop.length

        joined_file_contents[starting_counter..end_counter] = replacement_array.join

        nested_blocks = possible_blocks.clone.reject {|element| !element.include?(original_loop)}

        nested_blocks = nested_blocks.reject {|element| element.eql?(original_loop)}

        nested_blocks.each do |block|

          replacement_block = original_blocks[original_blocks.index(block)]

          starting_counter = replacement_block.index(original_loop)

          end_counter = replacement_block.index(original_loop)+original_loop.length

          replacement_block[starting_counter..end_counter] = replacement_array.join

          original_blocks[original_blocks.index(block)] = replacement_block

        end

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("appand","append")}

    return line_by_line_contents

  end