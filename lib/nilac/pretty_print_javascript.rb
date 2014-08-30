require_relative 'find_all_matching_indices'
require_relative 'read_file_line_by_line'
require_relative 'replace_strings'
require_relative 'strToArray'
  
  def pretty_print_javascript(javascript_file_contents, temporary_nila_file,declarable_variables,options)

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

    def fix_newlines(file_contents,main_block_numbers,options)

      def block_compactor(input_block)

        modified_block = input_block.reject {|element| element.strip.eql?("")}

        modified_block = modified_block.collect {|element| (element.rstrip + "\n") unless element[0..1].eql?("//")}

        return modified_block

      end

      main_block_numbers = [ ] if main_block_numbers.nil?

      unless main_block_numbers.empty?

        javascript_regexp = /(if |for |while |case |default:|switch\(|,function\(|\(function\(|= function\(|((=|:)\s+\{))/

        starting_locations = []

        file_contents.each_with_index do |line, index|

          if line.index(javascript_regexp) != nil

            starting_locations << index

          end

        end

        remaining_contents, blocks = roll_blocks(file_contents,starting_locations)

        modified_block = []

        blocks.each do |block|

          while block.join.include?("--block")

            nested_blocks = block.reject {|element| !replace_strings(element).include?("--block")}

            block_numbers = nested_blocks.collect {|element| element.strip.split("--block")[1].to_i}

            block_numbers.each_with_index do |number,index|

              location = block.index(nested_blocks[index])

              block[location] = blocks[number]

            end

            block = block.flatten

          end

          modified_block << block

        end

        main_block_numbers = main_block_numbers.collect {|element| element.strip.to_i}

        remaining_contents = remaining_contents.reject {|element| element.strip.eql?("")}

        remaining_contents[1...-1] = remaining_contents[1...-1].collect do |element|

          if !replace_strings(element).split("//")[0].eql?("")

            (element + "\n")

          else

            element

          end

        end

        remaining_contents = [remaining_contents[0]] + remaining_contents[1...-1] + [remaining_contents[-1]]

        main_block_numbers.each do |number|

          correct_block = block_compactor(modified_block[number])

          correct_block << "\n"

          remaining_contents[remaining_contents.index("--block#{number}\n\n")] = correct_block

        end

        remaining_contents = remaining_contents.flatten

      else

        remaining_contents = block_compactor(file_contents)

        remaining_contents[1...-1] = remaining_contents[1...-1].collect do |element|

          if !replace_strings(element).split("//")[0].eql?("")

            (element + "\n")

          else

            element

          end

        end

        unless options[:bare]

          remaining_contents = [remaining_contents[0]] + remaining_contents[1...-1] + [remaining_contents[-1]]

        end

      end

      remaining_contents[-1] = remaining_contents[-1].rstrip

      return remaining_contents

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

        possible_blocks.each do |block|

          if !block[0].eql?(current_block[-1])

            current_block += block

          else

            current_block += block[1..-1]

          end

          current_block.each_with_index do |line, index|

            if line.strip.eql? "}" or line.strip.eql?("};") or line.strip.include?("_!;") or line.strip.eql?("});")

              end_counter += 1

              end_index << index

            end

          end

          if end_counter > 0

            until end_index.empty?

              array_extract = current_block[0..end_index[0]].reverse

              index_counter = 0

              array_extract.each_with_index do |line|

                break if replace_strings(line).index(controlregexp) != nil

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

                if line.strip.eql? "}" or line.strip.eql?("};") or line.strip.include?("_!;") or line.strip.eql?("});")

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

      if input_file_contents.join.index(fixableregexp)

        need_fixes = input_file_contents.reject { |line| line.index(fixableregexp).nil? }

        need_fixes.each do |fix|

          input_file_contents[input_file_contents.index(fix)] = input_file_contents[input_file_contents.index(fix)].sub("  ", "")

        end

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

    def comment_fix(input_file_contents)

      def compress_block_comments(input_file_contents)

        joined_file_contents = input_file_contents.join

        block_comments = []

        while joined_file_contents.include?("/*")

          start_index = joined_file_contents.index("  /*")

          end_index = joined_file_contents.index("  */\n\n")

          if end_index > start_index

            block_comments << joined_file_contents[start_index..end_index + 5]

            joined_file_contents[start_index..end_index + 5] = ""

          end

        end

        block_comments.each do |comment|

          converted_array = strToArray(comment)

          converted_array = converted_array.reject {|element| element.strip.eql?("")}.collect {|element| element + "\n"}

          replacement_array = converted_array.collect {|element| element.rstrip + "\n"}

          replacement_array[-1] = replacement_array[-1] + "\n"

          replacement_array[1...-1] = replacement_array[1...-1].collect {|element| "  " + element}

          input_file_contents[input_file_contents.index(converted_array[0])..input_file_contents.index(converted_array[-1])] = replacement_array

        end

        return input_file_contents

      end

      input_file_contents = input_file_contents.collect do |element|

        line_counter = input_file_contents.index(element)

        if element[0..3].eql?("  //")

          if input_file_contents[line_counter+1].include?("//")

            element.rstrip + "\n"

          else

            element

          end

        else

          element

        end

      end

      input_file_contents = compress_block_comments(input_file_contents)

      return input_file_contents

    end

    def fix_spacing_issues(input_file_contents)

      # This method fixes all the spacing issues that causes jsHint errors.

    end

    javascript_regexp = /(if |for |while |case |default:|switch\(|\(function\(|= function\(|,\s*function\(|((=|:)\s+\{))/

    if declarable_variables.length > 0

      declaration_string = "var " + declarable_variables.flatten.uniq.sort.join(", ") + ";\n\n"

      javascript_file_contents = [declaration_string,javascript_file_contents].flatten

    end

    javascript_file_contents = javascript_file_contents.collect { |element| element.sub("Euuf", "if") }

    javascript_file_contents = javascript_file_contents.collect { |element| element.sub("whaaleskey", "while") }

    javascript_file_contents = javascript_file_contents.collect { |element| element.sub("}#@$", "}") }

    javascript_file_contents = reset_tabs(javascript_file_contents)

    starting_locations = []

    javascript_file_contents.each_with_index do |line, index|

      if replace_strings(line).index(javascript_regexp) != nil and !line.lstrip.split("//")[0].eql?("")

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

      if options[:strict_mode]

        remaining_file_contents = ["  \"use strict\";\n",remaining_file_contents].flatten

      end

      if options[:bare]

        remaining_file_contents = remaining_file_contents

      else

        remaining_file_contents = ["(function () {\n", remaining_file_contents, "\n}).call(this);"].flatten

      end

      main_blocks.each_with_index do |block_id, index|

        remaining_file_contents[remaining_file_contents.index(block_id)] = modified_blocks[index]

      end

      remaining_file_contents = remaining_file_contents.reject {|element| element.eql?("  ")}

      joined_file_contents = remaining_file_contents.join

    else

      if options[:bare]

        remaining_file_contents = remaining_file_contents.flatten

      else

        remaining_file_contents = remaining_file_contents.collect { |element| "  " + element }

        remaining_file_contents = ["(function () {\n", remaining_file_contents, "\n}).call(this);"].flatten

      end

      if options[:strict_mode] and options[:bare]

        remaining_file_contents = ["\"use strict\";\n",remaining_file_contents].flatten

      elsif options[:strict_mode] and options[:bare].eql?(false)

        remaining_file_contents = ["  \"use strict\";\n",remaining_file_contents].flatten

      end

      joined_file_contents = remaining_file_contents.join

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("%$%$ {","")}

    line_by_line_contents = fix_newlines(line_by_line_contents,main_block_numbers,options)

    if line_by_line_contents.join.include?("%$%$")

      removable_indices = line_by_line_contents.each_index.select {|index| line_by_line_contents[index].strip == "%$%$;" }

      while line_by_line_contents.join.include?("%$%$;")

        line_by_line_contents.delete_at(removable_indices[0])

        line_by_line_contents.delete_at(removable_indices[0])

        removable_indices = line_by_line_contents.each_index.select {|index| line_by_line_contents[index].strip == "%$%$;" }

      end

    end


    line_by_line_contents = fix_syntax_indentation(line_by_line_contents).compact

    line_by_line_contents = line_by_line_contents.collect { |element| replace_ignored_words(element) }

    line_by_line_contents =  comment_fix(line_by_line_contents)

    return line_by_line_contents

  end