require_relative 'read_file_line_by_line'
require_relative 'rollblocks'
require_relative 'replace_strings'

  
  def replace_named_functions(nila_file_contents, temporary_nila_file)

    final_modified_file_contents = nila_file_contents.clone

    joined_file_contents = final_modified_file_contents.join

    modified_file_contents = []

    rand_number = []

    nila_file_contents.each do |content|

      if replace_strings(content).include?("def ")

        rand_num = rand(1..25)

        while rand_number.include?(rand_num)

          rand_num = rand(1..10)

        end

        modified_file_contents << content.sub("def ","#{" "*rand_num}def ")

        rand_number << rand_num

      else

        modified_file_contents << content

      end

    end

    nila_file_contents = modified_file_contents.clone

    possible_function_blocks = nila_file_contents.reject {|element| !replace_strings(element).include?("def ")}

    function_block_locations = []

    possible_function_blocks.each do |block_start|

      function_block_locations << nila_file_contents.clone.each_index.select {|index| nila_file_contents[index] == block_start }

    end

    function_block_locations = function_block_locations.flatten

    function_block_locations = [0,function_block_locations,-1].flatten.uniq

    file_remains, code_blocks = extract_blocks(function_block_locations,final_modified_file_contents)

    modified_code_blocks = []

    code_blocks.each do |block|

      modified_code_blocks << block.collect {|element| element.gsub("\n\t\nend\n\t\n","}#@$")}

    end

    code_blocks = modified_code_blocks.clone

    named_code_blocks = code_blocks.clone.reject {|element| !replace_strings(element[0]).include?("def ")}

    modified_code_blocks = []

    code_blocks.each do |block|

      modified_code_blocks << block.collect {|element| element.gsub("")}

    end

    unless named_code_blocks.empty?

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

    named_functions = named_functions.reject {|element| element.empty?}

    nested_functions = nested_functions.reject {|element| element.empty?}

    return line_by_line_contents, named_functions, nested_functions

  end