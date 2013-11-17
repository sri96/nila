require_relative 'find_all_matching_indices'

require_relative 'read_file_line_by_line'
  
  def pretty_print_javascript(javascript_file_contents, temporary_nila_file,declarable_variables)

    def reset_tabs(input_file_contents)

      #This method removes all the predefined tabs to avoid problems in
      #later parts of the beautifying process.

      for x in 0...input_file_contents.length

        current_row = input_file_contents[x]

        if !current_row.eql?("\n")

          current_row = current_row.lstrip

        end

        input_file_contents[x] = current_row


      end

      return input_file_contents

    end

    def convert_string_to_array(input_string, temporary_nila_file)

      file_id = open(temporary_nila_file, 'w')

      file_id.write(input_string)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def fix_newlines(file_contents)

      def extract_blocks(file_contents)

        javascript_regexp = /(if |for |while |case |default:|switch\(|\(function\(|= function\(|,\s*function\(|((=|:)\s+\{))/

        block_starting_lines = file_contents.dup.reject { |element| element.index(javascript_regexp).nil? }[1..-1]

        block_starting_lines = block_starting_lines.reject { |element| element.include?("    ") }

        initial_starting_lines = block_starting_lines.dup

        starting_line_indices = []

        block_starting_lines.each do |line|

          starting_line_indices << file_contents.index(line)

        end

        block_ending_lines = file_contents.dup.each_index.select { |index| (file_contents[index].eql? "  }\n" or file_contents[index].eql? "  };\n" or file_contents[index].lstrip.eql?("});\n"))}

        block_ending_lines = block_ending_lines.reject {|index| file_contents[index].include?("    ")}

        modified_file_contents = file_contents.dup

        code_blocks = []

        starting_index = starting_line_indices[0]

        begin

          for x in 0...initial_starting_lines.length

            code_blocks << modified_file_contents[starting_index..block_ending_lines[0]]

            modified_file_contents[starting_index..block_ending_lines[0]] = []

            modified_file_contents.insert(starting_index, "  *****")

            block_starting_lines = modified_file_contents.dup.reject { |element| element.index(javascript_regexp).nil? }[1..-1]

            block_starting_lines = block_starting_lines.reject { |element| element.include?("    ") }

            starting_line_indices = []

            block_starting_lines.each do |line|

              starting_line_indices << modified_file_contents.index(line)

            end

            block_ending_lines = modified_file_contents.dup.each_index.select { |index| (modified_file_contents[index].eql? "  }\n" or modified_file_contents[index].eql? "  };\n" or modified_file_contents[index].lstrip.eql?("});\n")) }

            starting_index = starting_line_indices[0]

          end

        #rescue TypeError
        ##
        #  puts "Whitespace was left unfixed!"
        ##
        #rescue ArgumentError
        ##
        #  puts "Whitespace was left unfixed!"

        end

        return modified_file_contents, code_blocks

      end

      compact_contents = file_contents.reject { |element| element.lstrip.eql? "" }

      compact_contents, code_blocks = extract_blocks(compact_contents)

      processed_contents = compact_contents[1...-1].collect { |line| line+"\n" }

      compact_contents = [compact_contents[0]] + processed_contents + [compact_contents[-1]]

      code_block_locations = compact_contents.each_index.select { |index| compact_contents[index].eql? "  *****\n" }

      initial_locations = code_block_locations.dup

      starting_index = code_block_locations[0]

      for x in 0...initial_locations.length

        code_blocks[x][-1] = code_blocks[x][-1] + "\n"

        compact_contents = compact_contents[0...starting_index] + code_blocks[x] + compact_contents[starting_index+1..-1]

        code_block_locations = compact_contents.each_index.select { |index| compact_contents[index].eql? "  *****\n" }

        starting_index = code_block_locations[0]

      end

      return compact_contents

    end

    def roll_blocks(input_file_contents, code_block_starting_locations)

      if !code_block_starting_locations.empty?

        controlregexp = /(if |for |while |case |default:|switch\(|,function\(|\(function\(|= function\(|((=|:)\s+\{))/

        code_block_starting_locations = [0, code_block_starting_locations, -1].flatten

        possible_blocks = []

        block_counter = 0

        extracted_blocks = []

        for x in 0...code_block_starting_locations.length-1

          possible_blocks << input_file_contents[code_block_starting_locations[x]..code_block_starting_locations[x+1]]

          if possible_blocks.length > 1

            possible_blocks[-1] = possible_blocks[-1][1..-1]

          end

        end

        end_counter = 0

        end_index = []

        current_block = []

        possible_blocks.each_with_index do |block|

          if !block[0].eql?(current_block[-1])

            current_block += block

          else

            current_block += block[1..-1]

          end

          current_block.each_with_index do |line, index|

            if line.lstrip.eql? "}\n" or line.lstrip.eql?("};\n") or line.lstrip.include?("_!;\n") or line.lstrip.include?("});\n")

              end_counter += 1

              end_index << index

            end

          end

          if end_counter > 0

            until end_index.empty?

              array_extract = current_block[0..end_index[0]].reverse

              index_counter = 0

              array_extract.each_with_index do |line|

                break if line.index(controlregexp) != nil

                index_counter += 1

              end

              block_extract = array_extract[0..index_counter].reverse

              extracted_blocks << block_extract

              block_start = current_block.index(block_extract[0])

              block_end = current_block.index(block_extract[-1])

              current_block[block_start..block_end] = "--block#{block_counter}\n"

              block_counter += 1

              end_counter = 0

              end_index = []

              current_block.each_with_index do |line, index|

                if line.lstrip.eql? "}\n" or line.lstrip.eql?("};\n") or line.lstrip.include?("_!;\n") or line.lstrip.include?("});\n")

                  end_counter += 1

                  end_index << index

                end

              end

            end

          end

        end

        return current_block, extracted_blocks

      else

        return input_file_contents, []

      end

    end

    def fix_syntax_indentation(input_file_contents)

      fixableregexp = /(else |elsuf )/

      need_fixes = input_file_contents.reject { |line| line.index(fixableregexp).nil? }

      need_fixes.each do |fix|

        input_file_contents[input_file_contents.index(fix)] = input_file_contents[input_file_contents.index(fix)].sub("  ", "")

      end

      return input_file_contents

    end

    def replace_ignored_words(input_string)

      ignorable_keywords = [/if/, /while/, /function/,/function/]

      dummy_replacement_words = ["eeuuff", "whaalesskkey", "conffoolotion"]

      dummy_replacement_words.each_with_index do |word, index|

        input_string = input_string.sub(word, ignorable_keywords[index].inspect[1...-1])

      end

      return input_string

    end

    javascript_regexp = /(if |for |while |case |default:|switch\(|\(function\(|= function\(|((=|:)\s+\{))/

    if declarable_variables.length > 0

      declaration_string = "var " + declarable_variables.flatten.uniq.sort.join(", ") + ";\n\n"

      javascript_file_contents = [declaration_string,javascript_file_contents].flatten

    end

    javascript_file_contents = javascript_file_contents.collect { |element| element.sub("Euuf", "if") }

    javascript_file_contents = javascript_file_contents.collect { |element| element.sub("whaaleskey", "while") }

    javascript_file_contents = reset_tabs(javascript_file_contents)

    starting_locations = []

    javascript_file_contents.each_with_index do |line, index|

      if line.index(javascript_regexp) != nil

        starting_locations << index

      end

    end

    remaining_file_contents, blocks = roll_blocks(javascript_file_contents, starting_locations)

    joined_file_contents = ""

    if !blocks.empty?

      remaining_file_contents = remaining_file_contents.collect { |element| "  " + element }

      main_blocks = remaining_file_contents.reject { |element| !element.include?("--block") }

      main_block_numbers = main_blocks.collect { |element| element.split("--block")[1] }

      modified_blocks = main_blocks.dup

      soft_tabs = "  "

      for x in (0...main_blocks.length)

        soft_tabs_counter = 1

        current_block = blocks[main_block_numbers[x].to_i]

        current_block = [soft_tabs + current_block[0]] + current_block[1...-1] + [soft_tabs*(soft_tabs_counter)+current_block[-1]]

        soft_tabs_counter += 1

        current_block = [current_block[0]] + current_block[1...-1].collect { |element| soft_tabs*(soft_tabs_counter)+element } + [current_block[-1]]

        nested_block = current_block.clone.reject { |row| !row.include?("--block") }

        nested_block = nested_block.collect { |element| element.split("--block")[1] }

        nested_block = nested_block.collect { |element| element.rstrip.to_i }

        modified_nested_block = nested_block.clone

        current_block = current_block.join("\n")

        until modified_nested_block.empty?

          nested_block.each do |block_index|

            nested_block_contents = blocks[block_index]

            nested_block_contents = nested_block_contents[0...-1] + [soft_tabs*(soft_tabs_counter)+nested_block_contents[-1]]

            soft_tabs_counter += 1

            nested_block_contents = [nested_block_contents[0]] + nested_block_contents[1...-1].collect { |element| soft_tabs*(soft_tabs_counter)+element } + [nested_block_contents[-1]]

            nested_block_contents = nested_block_contents.reject { |element| element.gsub(" ", "").eql?("") }

            current_block = current_block.sub("--block#{block_index}", nested_block_contents.join)

            blocks[block_index] = nested_block_contents

            modified_nested_block.delete_at(0)

            soft_tabs_counter -= 1

          end

          current_block = convert_string_to_array(current_block, temporary_nila_file)

          nested_block = current_block.reject { |element| !element.include?("--block") }

          nested_block = nested_block.collect { |element| element.split("--block")[1] }

          nested_block = nested_block.collect { |element| element.rstrip.to_i }

          modified_nested_block = nested_block.clone

          current_block = current_block.join

          if !nested_block.empty?

            soft_tabs_counter += 1

          end

        end

        modified_blocks[x] = current_block

      end

      remaining_file_contents = ["(function() {\n", remaining_file_contents, "\n}).call(this);"].flatten

      joined_file_contents = remaining_file_contents.join

      main_blocks.each_with_index do |block_id, index|

        joined_file_contents = joined_file_contents.sub(block_id, modified_blocks[index])

      end

    else

      remaining_file_contents = remaining_file_contents.collect { |element| "  " + element }

      remaining_file_contents = ["(function() {\n", remaining_file_contents, "\n}).call(this);"].flatten

      joined_file_contents = remaining_file_contents.join

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("%$%$ {","")}

    line_by_line_contents = fix_newlines(line_by_line_contents)

    removable_indices = line_by_line_contents.each_index.select {|index| line_by_line_contents[index].strip == "%$%$;" }

    while line_by_line_contents.join.include?("%$%$;")

      line_by_line_contents.delete_at(removable_indices[0])

      line_by_line_contents.delete_at(removable_indices[0])

      removable_indices = line_by_line_contents.each_index.select {|index| line_by_line_contents[index].strip == "%$%$;" }

    end

    line_by_line_contents = fix_syntax_indentation(line_by_line_contents)

    line_by_line_contents = line_by_line_contents.collect { |element| replace_ignored_words(element) }

    return line_by_line_contents

  end