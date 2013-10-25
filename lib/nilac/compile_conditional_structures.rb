require_relative 'read_file_line_by_line'

def compile_conditional_structures(input_file_contents, temporary_nila_file)

  def replace_unless_until(input_file_contents)

    modified_file_contents = input_file_contents.clone

    possible_unless_commands = input_file_contents.reject { |element| !element.include?("unless") }

    unless_commands = possible_unless_commands.reject { |element| !element.lstrip.split("unless")[0].empty? }

    unless_commands.each do |command|

      junk, condition = command.split("unless ")

      condition = condition.gsub(" and "," && ").gsub(" or "," || ").gsub(" not "," !")

      replacement_string = "if !(#{condition.lstrip.rstrip})\n"

      modified_file_contents[modified_file_contents.index(command)] = replacement_string

    end

    possible_until_commands = input_file_contents.reject { |element| !element.include?("until") }

    until_commands = possible_until_commands.reject { |element| !element.lstrip.split("until")[0].empty? }

    until_commands.each do |command|

      junk, condition = command.split("until ")

      condition = condition.gsub(" and "," && ").gsub(" or "," || ").gsub(" not "," !")

      replacement_string = "while !(#{condition.lstrip.rstrip})\n"

      modified_file_contents[modified_file_contents.index(command)] = replacement_string

    end

    return modified_file_contents

  end

  def compile_ternary_if(input_file_contents)

    possible_ternary_if = input_file_contents.reject{|element| !element.include?("if")}

    possible_ternary_if = possible_ternary_if.reject {|element| !element.include?("then")}

    possible_ternary_if.each do |statement|

      statement_extract = statement[statement.index("if")..statement.index("end")+2]

      condition = statement_extract.split("then")[0].split("if")[1].lstrip.rstrip

      true_condition = statement_extract.split("then")[1].split("else")[0].lstrip.rstrip

      false_condition = statement_extract.split("else")[1].split("end")[0].lstrip.rstrip

      replacement_string = "#{condition} ? #{true_condition} : #{false_condition}"

      input_file_contents[input_file_contents.index(statement)] = input_file_contents[input_file_contents.index(statement)].sub(statement_extract,replacement_string)

    end

    return input_file_contents

  end

  def compile_inline_conditionals(input_file_contents, temporary_nila_file)

    conditionals = [/( if )/, /( while )/, /( unless )/, /( until )/]

    plain_conditionals = [" if ", " while ", " unless ", " until "]

    joined_file_contents = input_file_contents.join

    output_statement = ""

    conditionals.each_with_index do |regex, index|

      matching_lines = input_file_contents.reject { |content| content.index(regex).nil? }

      matching_lines.each do |line|

        line_split = line.split(plain_conditionals[index])

        condition = line_split[1]

        condition = condition.gsub(" and "," && ").gsub(" or "," || ").gsub(" not "," !")

        if index == 0

          output_statement = "if (#{condition.lstrip.rstrip.gsub("?", "")}) {\n\n#{line_split[0]}\n}\n"

        elsif index == 1

          output_statement = "while (#{condition.lstrip.rstrip.gsub("?", "")}) {\n\n#{line_split[0]}\n}\n"

        elsif index == 2

          output_statement = "if (!(#{condition.lstrip.rstrip.gsub("?", "")})) {\n\n#{line_split[0]}\n}\n"

        elsif index == 3

          output_statement = "while (!(#{condition.lstrip.rstrip.gsub("?", "")})) {\n\n#{line_split[0]}\n}\n"

        end

        joined_file_contents = joined_file_contents.sub(line, output_statement)

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def compile_regular_if(input_file_contents, temporary_nila_file)

    def convert_string_to_array(input_string, temporary_nila_file)

      file_id = open(temporary_nila_file, 'w')

      file_id.write(input_string)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def extract_if_blocks(if_statement_indexes, input_file_contents)

      possible_if_blocks = []

      if_block_counter = 0

      extracted_blocks = []

      controlregexp = /(if |while |def | do )/

      rejectionregexp = /( if | while )/

      for x in 0...if_statement_indexes.length-1

        possible_if_blocks << input_file_contents[if_statement_indexes[x]..if_statement_indexes[x+1]]

      end

      end_counter = 0

      end_index = []

      current_block = []

      possible_if_blocks.each_with_index do |block|

        unless current_block[-1] == block[0]

          current_block += block

        else

          current_block += block[1..-1]

        end


        current_block.each_with_index do |line, index|

          if line.strip.eql? "end"

            end_counter += 1

            end_index << index

          end

        end

        if end_counter > 0

          until end_index.empty?

            array_extract = current_block[0..end_index[0]].reverse

            index_counter = 0

            array_extract.each_with_index do |line|

              break if (line.lstrip.index(controlregexp) != nil and line.lstrip.index(rejectionregexp).nil?)

              index_counter += 1

            end

            block_extract = array_extract[0..index_counter].reverse

            extracted_blocks << block_extract

            block_start = current_block.index(block_extract[0])

            block_end = current_block.index(block_extract[-1])

            current_block[block_start..block_end] = "--ifblock#{if_block_counter}"

            if_block_counter += 1

            end_counter = 0

            end_index = []

            current_block.each_with_index do |line, index|

              if line.strip.eql? "end"

                end_counter += 1

                end_index << index

              end

            end

          end

        end

      end

      return current_block, extracted_blocks

    end

    def compile_if_syntax(input_block)

      strings = []

      string_counter = 0

      modified_input_block = input_block.dup

      input_block.each_with_index do |line, index|

        if line.include?("\"")

          opening_quotes = line.index("\"")

          string_extract = line[opening_quotes..line.index("\"", opening_quotes+1)]

          strings << string_extract

          modified_input_block[index] = modified_input_block[index].sub(string_extract, "--string{#{string_counter}}")

          string_counter += 1

        end

      end

      input_block = modified_input_block

      starting_line = input_block[0]

      starting_line = starting_line + "\n" if starting_line.lstrip == starting_line

      junk, condition = starting_line.split("if")

      condition = condition.gsub(" and "," && ").gsub(" or "," || ").gsub(" not "," !")

      input_block[0] = "Euuf (#{condition.lstrip.rstrip.gsub("?", "")}) {\n"

      input_block[-1] = input_block[-1].lstrip.sub("end", "}")

      elsif_statements = input_block.reject { |element| !element.include?("elsuf") }

      elsif_statements.each do |statement|

        junk, condition = statement.split("elsuf")

        condition = condition.gsub(" and "," && ").gsub(" or "," || ").gsub(" not "," !")

        input_block[input_block.index(statement)] = "} elsuf (#{condition.lstrip.rstrip.gsub("?", "")}) {\n"

      end

      else_statements = input_block.reject { |element| !element.include?("else") }

      else_statements.each do |statement|

        input_block[input_block.index(statement)] = "} else {\n"

      end

      modified_input_block = input_block.dup

      input_block.each_with_index do |line, index|

        if line.include?("--string{")

          junk, remains = line.split("--string{")

          string_index, junk = remains.split("}")

          modified_input_block[index] = modified_input_block[index].sub("--string{#{string_index.strip}}", strings[string_index.strip.to_i])

        end

      end

      return modified_input_block

    end

    input_file_contents = input_file_contents.collect { |element| element.sub("elsif", "elsuf") }

    possible_if_statements = input_file_contents.reject { |element| !element.include?("if") }

    possible_if_statements = possible_if_statements.reject { |element| element.include?("else") }

    possible_if_statements = possible_if_statements.reject { |element| element.lstrip.include?(" if ") }

    if !possible_if_statements.empty?

      if_statement_indexes = []

      possible_if_statements.each do |statement|

        if_statement_indexes << input_file_contents.dup.each_index.select { |index| input_file_contents[index] == statement }

      end

      if_statement_indexes = [0] + if_statement_indexes.flatten + [-1]

      controlregexp = /(while |def | do )/

      modified_input_contents, extracted_statements = extract_if_blocks(if_statement_indexes, input_file_contents.clone)

      joined_blocks = extracted_statements.collect { |element| element.join }

      if_statements = joined_blocks.reject { |element| element.index(controlregexp) != nil }

      rejected_elements = joined_blocks - if_statements

      rejected_elements_index = []

      rejected_elements.each do |element|

        rejected_elements_index << joined_blocks.each_index.select { |index| joined_blocks[index] == element }

      end

      if_blocks_index = (0...extracted_statements.length).to_a

      rejected_elements_index = rejected_elements_index.flatten

      if_blocks_index -= rejected_elements_index

      modified_if_statements = if_statements.collect { |string| convert_string_to_array(string, temporary_nila_file) }

      modified_if_statements = modified_if_statements.collect { |block| compile_if_syntax(block) }.reverse

      if_blocks_index = if_blocks_index.collect { |element| "--ifblock#{element}" }.reverse

      rejected_elements_index = rejected_elements_index.collect { |element| "--ifblock#{element}" }.reverse

      rejected_elements = rejected_elements.reverse

      joined_file_contents = modified_input_contents.join

      until if_blocks_index.empty? and rejected_elements_index.empty?

        if !if_blocks_index.empty?

          if joined_file_contents.include?(if_blocks_index[0])

            joined_file_contents = joined_file_contents.sub(if_blocks_index[0], modified_if_statements[0].join)

            if_blocks_index.delete_at(0)

            modified_if_statements.delete_at(0)

          else

            joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0])

            rejected_elements_index.delete_at(0)

            rejected_elements.delete_at(0)

          end

        else

          joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0])

          rejected_elements_index.delete_at(0)

          rejected_elements.delete_at(0)

        end

      end

    else

      joined_file_contents = input_file_contents.join

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def compile_regular_while(input_file_contents, temporary_nila_file)

    def convert_string_to_array(input_string, temporary_nila_file)

      file_id = open(temporary_nila_file, 'w')

      file_id.write(input_string)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def extract_while_blocks(while_statement_indexes, input_file_contents)

      possible_while_blocks = []

      while_block_counter = 0

      extracted_blocks = []

      controlregexp = /(if |while |def | do )/

      rejectionregexp = /( if | while )/

      for x in 0...while_statement_indexes.length-1

        possible_while_blocks << input_file_contents[while_statement_indexes[x]..while_statement_indexes[x+1]]

      end

      end_counter = 0

      end_index = []

      current_block = []

      possible_while_blocks.each_with_index do |block|

        current_block += block

        current_block.each_with_index do |line, index|

          if line.strip.eql? "end"

            end_counter += 1

            end_index << index

          end

        end

        if end_counter > 0

          until end_index.empty?

            array_extract = current_block[0..end_index[0]].reverse

            index_counter = 0

            array_extract.each_with_index do |line|

              break if (line.lstrip.index(controlregexp) != nil and line.lstrip.index(rejectionregexp).nil?)

              index_counter += 1

            end

            block_extract = array_extract[0..index_counter].reverse

            extracted_blocks << block_extract

            block_start = current_block.index(block_extract[0])

            block_end = current_block.index(block_extract[-1])

            current_block[block_start..block_end] = "--whileblock#{while_block_counter}"

            while_block_counter += 1

            end_counter = 0

            end_index = []

            current_block.each_with_index do |line, index|

              if line.strip.eql? "end"

                end_counter += 1

                end_index << index

              end

            end

          end

        end

      end

      return current_block, extracted_blocks

    end

    def compile_while_syntax(input_block)

      modified_input_block = input_block.dup

      strings = []

      string_counter = 0

      input_block.each_with_index do |line, index|

        if line.include?("\"")

          opening_quotes = line.index("\"")

          string_extract = line[opening_quotes..line.index("\"", opening_quotes+1)]

          strings << string_extract

          modified_input_block[index] = modified_input_block[index].sub(string_extract, "--string{#{string_counter}}")

          string_counter += 1

        end

      end

      input_block = modified_input_block

      starting_line = input_block[0]

      starting_line = starting_line + "\n" if starting_line.lstrip == starting_line

      junk, condition = starting_line.split("while")

      input_block[0] = "whaaleskey (#{condition.lstrip.rstrip.gsub("?", "")}) {\n"

      input_block[-1] = input_block[-1].lstrip.sub("end", "}")

      modified_input_block = input_block.dup

      input_block.each_with_index do |line, index|

        if line.include?("--string{")

          junk, remains = line.split("--string{")

          string_index, junk = remains.split("}")

          modified_input_block[index] = modified_input_block[index].sub("--string{#{string_index.strip}}", strings[string_index.strip.to_i])

        end

      end

      return modified_input_block

    end

    possible_while_statements = input_file_contents.reject { |element| !element.include?("while") }

    if !possible_while_statements.empty?

      while_statement_indexes = []

      possible_while_statements.each do |statement|

        while_statement_indexes << input_file_contents.dup.each_index.select { |index| input_file_contents[index] == statement }

      end

      while_statement_indexes = [0] + while_statement_indexes.flatten + [-1]

      controlregexp = /(if |def | do )/

      modified_input_contents, extracted_statements = extract_while_blocks(while_statement_indexes, input_file_contents.clone)

      joined_blocks = extracted_statements.collect { |element| element.join }

      while_statements = joined_blocks.reject { |element| element.index(controlregexp) != nil }

      rejected_elements = joined_blocks - while_statements

      rejected_elements_index = []

      rejected_elements.each do |element|

        rejected_elements_index << joined_blocks.each_index.select { |index| joined_blocks[index] == element }

      end

      while_blocks_index = (0...extracted_statements.length).to_a

      rejected_elements_index = rejected_elements_index.flatten

      while_blocks_index -= rejected_elements_index

      modified_while_statements = while_statements.collect { |string| convert_string_to_array(string, temporary_nila_file) }

      modified_while_statements = modified_while_statements.collect { |block| compile_while_syntax(block) }.reverse

      while_blocks_index = while_blocks_index.collect { |element| "--whileblock#{element}" }.reverse

      rejected_elements_index = rejected_elements_index.collect { |element| "--whileblock#{element}" }.reverse

      rejected_elements = rejected_elements.reverse

      joined_file_contents = modified_input_contents.join

      until while_blocks_index.empty? and rejected_elements_index.empty?

        if !while_blocks_index.empty?

          if joined_file_contents.include?(while_blocks_index[0])

            joined_file_contents = joined_file_contents.sub(while_blocks_index[0], modified_while_statements[0].join)

            while_blocks_index.delete_at(0)

            modified_while_statements.delete_at(0)

          else

            joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0])

            rejected_elements_index.delete_at(0)

            rejected_elements.delete_at(0)

          end

        else

          joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0])

          rejected_elements_index.delete_at(0)

          rejected_elements.delete_at(0)

        end

      end

    else

      joined_file_contents = input_file_contents.join

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def compile_regular_for(input_file_contents, temporary_nila_file)

    def convert_string_to_array(input_string, temporary_nila_file)

      file_id = open(temporary_nila_file, 'w')

      file_id.write(input_string)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def extract_for_blocks(for_statement_indexes, input_file_contents)

      possible_for_blocks = []

      for_block_counter = 0

      extracted_blocks = []

      controlregexp = /(if |while |def |for | do )/

      rejectionregexp = /( if | while )/

      for x in 0...for_statement_indexes.length-1

        possible_for_blocks << input_file_contents[for_statement_indexes[x]..for_statement_indexes[x+1]]

      end

      end_counter = 0

      end_index = []

      current_block = []

      possible_for_blocks.each_with_index do |block|

        current_block += block

        current_block.each_with_index do |line, index|

          if line.strip.eql? "end"

            end_counter += 1

            end_index << index

          end

        end

        if end_counter > 0

          until end_index.empty?

            array_extract = current_block[0..end_index[0]].reverse

            index_counter = 0

            array_extract.each_with_index do |line|

              break if (line.lstrip.index(controlregexp) != nil and line.lstrip.index(rejectionregexp).nil?)

              index_counter += 1

            end

            block_extract = array_extract[0..index_counter].reverse

            extracted_blocks << block_extract

            block_start = current_block.index(block_extract[0])

            block_end = current_block.index(block_extract[-1])

            current_block[block_start..block_end] = "--forblock#{for_block_counter}"

            for_block_counter += 1

            end_counter = 0

            end_index = []

            current_block.each_with_index do |line, index|

              if line.strip.eql? "end"

                end_counter += 1

                end_index << index

              end

            end

          end

        end

      end

      return current_block, extracted_blocks

    end

    def compile_for_syntax(input_block)

      def compile_condition(input_condition, input_block)

        variable,array_name = input_condition.split("in")

        if array_name.strip.include?("[") and array_name.strip.include?("]")

          replacement_array = "_ref1 = #{array_name.strip}\n\n"

          replacement_string = "#{variable.strip} = _ref1[_i];\n\n"

          input_block = [replacement_array] + input_block.insert(1,replacement_string)

          input_block[1] = "for (_i = 0, _j = _ref1.length; _i < _j; _i += 1) {\n\n"

        elsif array_name.strip.include?("..")

          array_type = if array_name.strip.include?("...") then 0 else 1 end

          if array_type == 0

            num1,num2 = array_name.strip.split("...")

            input_block[0] = "for (#{variable.strip} = #{num1}, _j = #{num2}; #{variable.strip} <= _j; #{variable.strip} += 1) {\n\n"

          else

            num1,num2 = array_name.strip.split("..")

            input_block[0] = "for (#{variable.strip} = #{num1}, _j = #{num2}; #{variable.strip} < _j; #{variable.strip} += 1) {\n\n"

          end

        else

          input_block[0] = "for (_i = 0, _j = #{array_name.strip}.length; _i < _j; _i += 1) {\n\n"

          input_block = input_block.insert(1,"#{variable.strip} = #{array_name.strip}[_i];\n\n")

        end

        return input_block

      end

      modified_input_block = input_block.dup

      strings = []

      string_counter = 0

      input_block.each_with_index do |line, index|

        if line.include?("\"")

          opening_quotes = line.index("\"")

          string_extract = line[opening_quotes..line.index("\"", opening_quotes+1)]

          strings << string_extract

          modified_input_block[index] = modified_input_block[index].sub(string_extract, "--string{#{string_counter}}")

          string_counter += 1

        end

      end

      input_block = modified_input_block

      starting_line = input_block[0]

      starting_line = starting_line + "\n" if starting_line.lstrip == starting_line

      junk, condition = starting_line.split("for")

      input_block[-1] = input_block[-1].lstrip.sub("end", "}")

      input_block = compile_condition(condition,input_block)

      modified_input_block = input_block.dup

      input_block.each_with_index do |line, index|

        if line.include?("--string{")

          junk, remains = line.split("--string{")

          string_index, junk = remains.split("}")

          modified_input_block[index] = modified_input_block[index].sub("--string{#{string_index.strip}}", strings[string_index.strip.to_i])

        end

      end

      return modified_input_block

    end

    possible_for_statements = input_file_contents.reject { |element| !element.include?("for") }

    possible_for_statements = possible_for_statements.reject {|element| element.include?("for (")}

    if !possible_for_statements.empty?

      for_statement_indexes = []

      possible_for_statements.each do |statement|

        for_statement_indexes << input_file_contents.dup.each_index.select { |index| input_file_contents[index] == statement }

      end

      for_statement_indexes = [0] + for_statement_indexes.flatten + [-1]

      controlregexp = /(if |def |while | do )/

      modified_input_contents, extracted_statements = extract_for_blocks(for_statement_indexes, input_file_contents.clone)

      joined_blocks = extracted_statements.collect { |element| element.join }

      for_statements = joined_blocks.reject { |element| element.index(controlregexp) != nil }

      rejected_elements = joined_blocks - for_statements

      rejected_elements_index = []

      rejected_elements.each do |element|

        rejected_elements_index << joined_blocks.each_index.select { |index| joined_blocks[index] == element }

      end

      for_blocks_index = (0...extracted_statements.length).to_a

      rejected_elements_index = rejected_elements_index.flatten

      for_blocks_index -= rejected_elements_index

      modified_for_statements = for_statements.collect { |string| convert_string_to_array(string, temporary_nila_file) }

      modified_for_statements = modified_for_statements.collect { |block| compile_for_syntax(block) }.reverse

      for_blocks_index = for_blocks_index.collect { |element| "--forblock#{element}" }.reverse

      rejected_elements_index = rejected_elements_index.collect { |element| "--forblock#{element}" }.reverse

      rejected_elements = rejected_elements.reverse

      joined_file_contents = modified_input_contents.join

      until for_blocks_index.empty? and rejected_elements_index.empty?

        if !for_blocks_index.empty?

          if joined_file_contents.include?(for_blocks_index[0])

            joined_file_contents = joined_file_contents.sub(for_blocks_index[0], modified_for_statements[0].join)

            for_blocks_index.delete_at(0)

            modified_for_statements.delete_at(0)

          else

            joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0].join)

            rejected_elements_index.delete_at(0)

            rejected_elements.delete_at(0)

          end

        else

          joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0])

          rejected_elements_index.delete_at(0)

          rejected_elements.delete_at(0)

        end

      end

    else

      joined_file_contents = input_file_contents.join

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def compile_loop_keyword(input_file_contents,temporary_nila_file)

    def convert_string_to_array(input_string, temporary_nila_file)

      file_id = open(temporary_nila_file, 'w')

      file_id.write(input_string)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def extract_loop_blocks(loop_statement_indexes, input_file_contents)

      possible_loop_blocks = []

      loop_block_counter = 0

      extracted_blocks = []

      controlregexp = /(if |while |def |loop )/

      rejectionregexp = /( if | while )/

      for x in 0...loop_statement_indexes.length-1

        possible_loop_blocks << input_file_contents[loop_statement_indexes[x]..loop_statement_indexes[x+1]]

      end

      end_counter = 0

      end_index = []

      current_block = []

      possible_loop_blocks.each_with_index do |block|

        current_block += block

        current_block.each_with_index do |line, index|

          if line.strip.eql? "end"

            end_counter += 1

            end_index << index

          end

        end

        if end_counter > 0

          until end_index.empty?

            array_extract = current_block[0..end_index[0]].reverse

            index_counter = 0

            array_extract.each_with_index do |line|

              break if (line.lstrip.index(controlregexp) != nil and line.lstrip.index(rejectionregexp).nil?)

              index_counter += 1

            end

            block_extract = array_extract[0..index_counter].reverse

            extracted_blocks << block_extract

            block_start = current_block.index(block_extract[0])

            block_end = current_block.index(block_extract[-1])

            current_block[block_start..block_end] = "--loopblock#{loop_block_counter}"

            loop_block_counter += 1

            end_counter = 0

            end_index = []

            current_block.each_with_index do |line, index|

              if line.strip.eql? "end"

                end_counter += 1

                end_index << index

              end

            end

          end

        end

      end

      return current_block, extracted_blocks

    end

    def compile_loop_syntax(input_block)

      modified_input_block = input_block.dup

      strings = []

      string_counter = 0

      input_block.each_with_index do |line, index|

        if line.include?("\"")

          opening_quotes = line.index("\"")

          string_extract = line[opening_quotes..line.index("\"", opening_quotes+1)]

          strings << string_extract

          modified_input_block[index] = modified_input_block[index].sub(string_extract, "--string{#{string_counter}}")

          string_counter += 1

        end

      end

      input_block = modified_input_block

      starting_line = input_block[0]

      starting_line = starting_line + "\n" if starting_line.lstrip == starting_line

      input_block[0] = "whaaleskey (true) {\n"

      input_block[-1] = input_block[-1].lstrip.sub("end", "}")

      modified_input_block = input_block.dup

      input_block.each_with_index do |line, index|

        if line.include?("--string{")

          junk, remains = line.split("--string{")

          string_index, junk = remains.split("}")

          modified_input_block[index] = modified_input_block[index].sub("--string{#{string_index.strip}}", strings[string_index.strip.to_i])

        end

      end

      return modified_input_block

    end

    possible_loop_statements = input_file_contents.reject { |element| !element.include?("loop") }

    if !possible_loop_statements.empty?

      loop_statement_indexes = []

      possible_loop_statements.each do |statement|

        loop_statement_indexes << input_file_contents.dup.each_index.select { |index| input_file_contents[index] == statement }

      end

      loop_statement_indexes = [0] + loop_statement_indexes.flatten + [-1]

      controlregexp = /(if |def )/

      modified_input_contents, extracted_statements = extract_loop_blocks(loop_statement_indexes, input_file_contents.clone)

      joined_blocks = extracted_statements.collect { |element| element.join }

      loop_statements = joined_blocks.reject { |element| element.index(controlregexp) != nil }

      rejected_elements = joined_blocks - loop_statements

      rejected_elements_index = []

      rejected_elements.each do |element|

        rejected_elements_index << joined_blocks.each_index.select { |index| joined_blocks[index] == element }

      end

      loop_blocks_index = (0...extracted_statements.length).to_a

      rejected_elements_index = rejected_elements_index.flatten

      loop_blocks_index -= rejected_elements_index

      modified_loop_statements = loop_statements.collect { |string| convert_string_to_array(string, temporary_nila_file) }

      modified_loop_statements = modified_loop_statements.collect { |block| compile_loop_syntax(block) }.reverse

      loop_blocks_index = loop_blocks_index.collect { |element| "--loopblock#{element}" }.reverse

      rejected_elements_index = rejected_elements_index.collect { |element| "--loopblock#{element}" }.reverse

      rejected_elements = rejected_elements.reverse

      joined_file_contents = modified_input_contents.join

      until loop_blocks_index.empty? and rejected_elements_index.empty?

        if !loop_blocks_index.empty?

          if joined_file_contents.include?(loop_blocks_index[0])

            joined_file_contents = joined_file_contents.sub(loop_blocks_index[0], modified_loop_statements[0].join)

            loop_blocks_index.delete_at(0)

            modified_loop_statements.delete_at(0)

          else

            joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0].join)

            rejected_elements_index.delete_at(0)

            rejected_elements.delete_at(0)

          end

        else

          joined_file_contents = joined_file_contents.sub(rejected_elements_index[0], rejected_elements[0].join)

          rejected_elements_index.delete_at(0)

          rejected_elements.delete_at(0)

        end

      end

    else

      joined_file_contents = input_file_contents.join

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def ignore_statement_modifiers(input_block)

    modified_input_block = input_block.dup

    rejectionregexp = /( if | while )/

    rejected_lines = {}

    rejected_line_counter = 0

    input_block.each_with_index do |line, index|

      if line.lstrip.index(rejectionregexp) != nil

        rejected_lines["--rejected{#{rejected_line_counter}}\n\n"] = line

        modified_input_block[index] = "--rejected{#{rejected_line_counter}}\n\n"

        rejected_line_counter += 1

      end

    end

    return modified_input_block, rejected_lines

  end

  def replace_statement_modifiers(input_block, rejected_lines)

    unless rejected_lines.empty?

      rejected_replacements = rejected_lines.keys

      loc = 0

      indices = []

      index_counter = 0

      rejected_replacements.each do |replacement_string|

        input_block.each_with_index do |line, index|

          break if line.include?(replacement_string.rstrip)

          index_counter += 1

        end

        indices << index_counter

        index_counter = 0

      end

      indices.each_with_index do |location, index|

        input_block[location] = rejected_lines.values[index] + "\n\n"

      end

    end

    return input_block

  end

  file_contents = compile_ternary_if(input_file_contents)

  file_contents, rejected_lines = ignore_statement_modifiers(file_contents)

  file_contents = replace_unless_until(file_contents)

  file_contents = compile_regular_if(file_contents, temporary_nila_file)

  file_contents = compile_regular_for(file_contents, temporary_nila_file)

  file_contents = compile_regular_while(file_contents, temporary_nila_file)

  file_contents = compile_loop_keyword(file_contents,temporary_nila_file)

  file_contents = replace_statement_modifiers(file_contents, rejected_lines)

  file_contents = compile_inline_conditionals(file_contents, temporary_nila_file)

  return file_contents

end