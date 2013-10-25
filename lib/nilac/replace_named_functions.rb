require_relative 'read_file_line_by_line'
  
  def replace_named_functions(nila_file_contents, temporary_nila_file)

    def extract_array(input_array, start_index, end_index)

      return input_array[start_index..end_index]

    end

    end_locations = []

    key_word_locations = []

    start_blocks = []

    end_blocks = []

    nila_regexp = /(def )/

    named_code_blocks = []

    for x in 0...nila_file_contents.length

      current_row = nila_file_contents[x]

      if current_row.index(nila_regexp) != nil

        key_word_locations << x

      elsif current_row.lstrip.eql?("end\n") || current_row.strip.eql?("end")

        end_locations << x


      end


    end

    unless key_word_locations.empty?

      modified_file_contents = nila_file_contents.dup

      for y in 0...end_locations.length

        current_location = end_locations[y]

        current_string = modified_file_contents[current_location]

        finder_location = current_location

        begin

          while current_string.index(nila_regexp) == nil

            finder_location -= 1

            current_string = modified_file_contents[finder_location]

          end

          code_block_begin = finder_location

          code_block_end = current_location

          start_blocks << code_block_begin

          end_blocks << code_block_end

          code_block_begin_string_split = modified_file_contents[code_block_begin].split(" ")

          code_block_begin_string_split[0] = code_block_begin_string_split[0].reverse

          code_block_begin_string = code_block_begin_string_split.join(" ")

          modified_file_contents[code_block_begin] = code_block_begin_string

        rescue NoMethodError
        
          puts "Function compilation failed!"

        end

      end

      final_modified_file_contents = nila_file_contents.dup

      joined_file_contents = final_modified_file_contents.join

      while start_blocks.length != 0

        top_most_level = start_blocks.min

        top_most_level_index = start_blocks.index(top_most_level)

        matching_level = end_blocks[top_most_level_index]

        named_code_blocks << extract_array(final_modified_file_contents, top_most_level, matching_level)

        start_blocks.delete_at(top_most_level_index)

        end_blocks.delete(matching_level)

      end

      codeblock_counter = 1

      named_functions = named_code_blocks.dup

      nested_functions = []

      named_code_blocks.each do |codeblock|

        if joined_file_contents.include?(codeblock.join)

          joined_file_contents = joined_file_contents.sub(codeblock.join, "--named_function[#{codeblock_counter}]\n")

          codeblock_counter += 1

          nested_functions = nested_functions + [[]]

        else

          nested_functions[codeblock_counter-2] << codeblock

          named_functions.delete(codeblock)

        end

      end

    else

      joined_file_contents = nila_file_contents.join

      named_functions = []

      nested_functions = []

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents, named_functions, nested_functions


  end