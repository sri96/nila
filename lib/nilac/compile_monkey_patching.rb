# Monkey Patching is an interesting concept. But fair warning, it is not recommended in the Javascript community.
# We are just implementing it so that we can learn more about Ruby and its Javascript counterpart. This will also serve
# as a starting point to implement classes.

require_relative 'rollblocks'
require_relative 'replace_strings'
require_relative 'read_file_line_by_line'

def compile_monkey_patching(input_file_contents,temporary_nila_file)

  def extract_class_name(input_class_start)

    class_split = input_class_start.strip.split("class ")

    return class_split[1]

  end

  def monkey_patch_errors(input_classes)

    def extract_function_name(input_block_start)

      first_line = input_block_start

      first_line_split = first_line.split("=")

      return first_line_split[0]

    end

    def multiple_same_name_methods(input_class)

      message = ""

      input_class = input_class.collect {|element| element.gsub("(function","&F(^u@#N(C%%")}

      method_blocks = input_class.reject {|element| !replace_strings(element).include?("= function")}

      function_names = []

      proceed_to_next = true

      method_blocks.each do |method_start|

        extract_name = extract_function_name(method_start)

        if function_names.include?(extract_name)

          proceed_to_next = false

          break

        end

        function_names << extract_name

      end

      if proceed_to_next == false

        puts "Hey I discovered two methods by the same name under a potential monkey patched/duck punched Prototype.\n\n"

        puts "Unfortunately that is not allowed because one of your patches is going to be overridden by the other patch.\n\n"

        puts "Please consider changing the code to make sure that all of your patch methods are unique. "

      end

      return proceed_to_next

    end

    proceed_to_next = true

    class_counter = 0

    while proceed_to_next and input_classes.length > class_counter

      proceed_to_next = multiple_same_name_methods(input_classes[class_counter])

      class_counter += 1

    end

    return proceed_to_next

  end

  input_file_contents = input_file_contents.collect {|element| element.gsub("}#@$","}")}

  joined_file_contents = input_file_contents.join

  possible_class_statements = input_file_contents.reject {|element| !replace_strings(element).include?("class ")}

  class_statement_indices = []

  possible_class_statements.each do |statement|

   class_statement_indices << input_file_contents.each_index.select {|index| input_file_contents[index] == statement}

  end

  class_statement_indices = [0,class_statement_indices,-1].flatten.uniq

  file_remains, blocks = extract_blocks(class_statement_indices,input_file_contents,["class","function"])

  class_blocks = blocks.reject {|element| !replace_strings(element[0]).include?("class ")}

  class_blocks = class_blocks.reject {|element| replace_strings(element.join).include?("initialize =")}

  proceed = monkey_patch_errors(class_blocks)

  if proceed

    class_blocks.each do |block|

      class_name = extract_class_name(block[0])

      block = block.collect {|element| element.gsub("(function","&F(^u@#N(C%%")}

      method_starters = block.reject {|element| !replace_strings(element).include?("= function")}

      method_locations = []

      method_starters.each do |element|

        method_locations << block.each_index.select {|index| block[index] == element}

      end

      method_locations = [0,method_locations,-1].flatten.uniq


      block_remains, sub_blocks = extract_blocks(method_locations,block[1...-1],["function"])

      sub_method_blocks = sub_blocks.reject {|element| !replace_strings(element[0]).include?("= function")}

      modified_method_blocks = []

      sub_method_blocks.each do |block|

        block[0] = class_name.capitalize + ".prototype." + block[0]

        block = block.collect {|element| element.gsub("&F(^u@#N(C%%","(function")}

        modified_method_blocks << []

        block.each do |statement|

          if replace_strings(statement).include?("self")

            modified_method_blocks[-1] << statement.gsub("self","this")

          else

            modified_method_blocks[-1] << statement

          end

        end


      end

      modified_method_blocks.each_with_index do |block,index|

        sub_blocks[sub_blocks.index(sub_method_blocks[index])] = block

      end

      block = block.collect {|element| element.gsub("&F(^u@#N(C%%","(function")}

      joined_file_contents = joined_file_contents.sub(block.join,sub_blocks.join)

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    file_contents = read_file_line_by_line(temporary_nila_file)

    return file_contents

  end

end