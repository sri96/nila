require_relative 'replace_strings'

def extract_blocks(statement_indexes, input_file_contents,options = [])

  possible_blocks = []

  block_counter = 0

  extracted_blocks = []

  input_file_contents = input_file_contents.collect {|element| element.gsub("}#@$","\n\t\nend\n\t\n")}

  input_file_contents = input_file_contents.collect {|element| element.gsub("};","\t\t}\n\t")} if options.length.eql?(5)

  controlregexp = /(if |Euuf |while |for |def | do |class )/ if options.empty?

  controlregexp = /(if |while |class |= function)/ if options.length.eql?(1)

  controlregexp = /(if |while |def | do |class )/ if options.length.eql?(2)

  controlregexp = /(Euuf |while |for | do |function )/ if options.length.eql?(5)

  endexpr = "end" if options.empty?

  endexpr = "};" if options.length.eql?(1)

  endexpr = "end" if options.length.eql?(2)

  endexpr = "}" if options.length.eql?(5)

  for x in 0...statement_indexes.length-1

    possible_blocks << input_file_contents[statement_indexes[x]..statement_indexes[x+1]]

  end

  end_counter = 0

  end_index = []

  current_block = []

  possible_blocks.each_with_index do |block|

    unless current_block[-1] == block[0]

      current_block += block

    else

      current_block += block[1..-1]

    end

    current_block.each_with_index do |line, index|

      if line.strip.eql? endexpr

        end_counter += 1

        end_index << index

      end

    end

    if end_counter > 0

      until end_index.empty?

        array_extract = current_block[0..end_index[0]].reverse

        index_counter = 0

        array_extract.each_with_index do |line|

          break if (line.lstrip.index(controlregexp) != nil)

          index_counter += 1

        end

        block_extract = array_extract[0..index_counter].reverse

        extracted_blocks << block_extract

        block_start = current_block.index(block_extract[0])

        block_end = current_block.index(block_extract[-1])

        current_block[block_start..block_end] = "--block#{block_counter}"

        block_counter += 1

        end_counter = 0

        end_index = []

        current_block.each_with_index do |line, index|

          if line.strip.eql? endexpr

            end_counter += 1

            end_index << index

          end

        end

      end

    end

  end

  modified_blocks = extracted_blocks.clone

  modified_blocks.each_with_index do |block,index|

    extracted_blocks[index] = block.collect {|element| element.gsub("\n\t\nend\n\t\n","}#@$")}

    extracted_blocks[index] = block.collect {|element| element.gsub("\t\t}\n\t","};")}

  end

  if options.length == 5

    output_blocks = extracted_blocks

    main_block = extracted_blocks.reject {|element| !replace_strings(element[0]).index(/function /)}

    return main_block.flatten,output_blocks

  else

  modified_rolled_blocks = []

  rolled_blocks = extracted_blocks.reject {|element| !replace_strings(element.join).include?("--block")}

  rolled_blocks.each do |block|

    included_blocks = block.reject {|element| !replace_strings(element).include?("--block")}

    matching_blocks = included_blocks.collect {|element| element.split("--block")[1].to_i}

    while block.join.include?("--block")

      block[block.index(included_blocks[0])] = extracted_blocks[matching_blocks[0]]

      included_blocks.delete_at(0)

      matching_blocks.delete_at(0)

    end

    modified_rolled_blocks << block

  end

  rolled_blocks.each_with_index do |block,index|

    extracted_blocks[extracted_blocks.index(block)] = modified_rolled_blocks[index]

  end

  extracted_blocks = extracted_blocks.collect {|element| element.flatten}

  return current_block, extracted_blocks

  end

end