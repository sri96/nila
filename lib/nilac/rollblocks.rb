def extract_blocks(statement_indexes, input_file_contents)

  possible_if_blocks = []

  if_block_counter = 0

  extracted_blocks = []

  controlregexp = /(if |while |def | do )/

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