require_relative 'read_file_line_by_line'
  
  def compile_loops(input_file_contents,temporary_nila_file)

    def compile_times_loop(input_file_contents,temporary_nila_file)

      def compile_one_line_blocks(input_block)

        block_parameters, block_contents = input_block[1...-1].split("|",2)[1].split("|",2)

        compiled_block = "(function(#{block_parameters.lstrip.rstrip}) {\n\n  #{block_contents.strip} \n\n}(_i))_!;\n"

        return compiled_block

      end

      def extract_variable_names(input_file_contents)

        variables = []

        input_file_contents = input_file_contents.collect { |element| element.gsub("==", "equalequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("!=", "notequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("+=", "plusequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("-=", "minusequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("*=", "multiequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("/=", "divequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("%=", "modequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("=~", "matchequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub(">=", "greatequal") }

        input_file_contents = input_file_contents.collect { |element| element.gsub("<=", "lessyequal") }

        javascript_regexp = /(if |while |for )/

        for x in 0...input_file_contents.length

          current_row = input_file_contents[x]

          if current_row.include?("=") and current_row.index(javascript_regexp) == nil

            current_row = current_row.rstrip + "\n"

            current_row_split = current_row.split("=")

            for y in 0...current_row_split.length

              current_row_split[y] = current_row_split[y].strip


            end

            if current_row_split[0].include?("[") or current_row_split[0].include?("(")

              current_row_split[0] = current_row_split[0][0...current_row_split[0].index("[")]

            end

            variables << current_row_split[0]


          end

          input_file_contents[x] = current_row

        end

        variables += ["_i","_j"]

        variables = variables.flatten

        return variables.uniq

      end

      possible_times_loop = input_file_contents.reject{ |element| !element.include?(".times")}

      multiline_times_loop = possible_times_loop.reject {|element| !element.include?(" do ")}

      unless multiline_times_loop.empty?

        multiline_times_loop.each do |starting_line|

          index_counter = starting_counter = input_file_contents.index(starting_line)

          line = starting_line

          until line.strip.eql?("end")

            index_counter += 1

            line = input_file_contents[index_counter]

          end

          loop_extract = input_file_contents[starting_counter..index_counter]

          file_extract = input_file_contents[0..index_counter]

          file_variables = extract_variable_names(file_extract)

          block_variables = extract_variable_names(loop_extract)

          var_need_of_declaration = file_variables-block_variables-["_i","_j"]

          loop_condition, block = loop_extract.join.split(" do ")

          block = block.split("end")[0]

          replacement_string = "#{loop_condition.rstrip} {#{block.strip}}"

          input_file_contents[starting_counter..index_counter] = replacement_string

        end

      end

      possible_times_loop = input_file_contents.reject{ |element| !element.include?(".times")}

      oneliner_times_loop = possible_times_loop.reject {|element| !element.include?("{") and !element.include?("}")}

      loop_variables = []

      modified_file_contents = input_file_contents.clone

      unless oneliner_times_loop.empty?

        oneliner_times_loop.each do |loop|

          original_loop = loop.clone

          string_counter = 1

          extracted_string = []

          while loop.include?("\"")

            string_extract = loop[loop.index("\"")..loop.index("\"",loop.index("\"")+1)]

            extracted_string << string_extract

            loop = loop.sub(string_extract,"--repstring#{string_counter}")

            string_counter += 1

          end

          block_extract = loop[loop.index("{")..loop.index("}")]

          compiled_block = ""

          if block_extract.count("|") == 2

            compiled_block = compile_one_line_blocks(block_extract)

            extracted_string.each_with_index do |string,index|

              compiled_block = compiled_block.sub("--repstring#{index+1}",string)

            end

          else

            compiled_block = block_extract[1...-1].lstrip.rstrip

            extracted_string.each_with_index do |string,index|

              compiled_block = compiled_block.sub("--repstring#{index+1}",string)

            end

          end

          times_counter = loop.split(".times")[0].lstrip

          times_counter = times_counter[1...-1] if times_counter.include?("(") and times_counter.include?(")")

          replacement_string = "for (_i = 0, _j = #{times_counter}; _i < _j; _i += 1) {\n\n#{compiled_block}\n\n}\n\n\n"

          modified_file_contents[input_file_contents.index(original_loop)] = replacement_string

        end

        loop_variables = ["_i","_j"]

      end

      file_id = open(temporary_nila_file, 'w')

      file_id.write(modified_file_contents.join)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents,loop_variables

    end

    file_contents,loop_variables = compile_times_loop(input_file_contents,temporary_nila_file)

    return file_contents,loop_variables

  end