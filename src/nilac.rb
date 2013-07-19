#Nilac is the official Nila compiler. It compiles Nila into pure Javascript. Nilac is currently
#written in Ruby but will be self hosted in the upcoming years.

#Nila and Nilac are being crafted by Adhithya Rajasekaran and Sri Madhavi Rajasekaran

require 'slop'
require 'fileutils'

def compile(input_file_path,*output_file_name)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  def extract_parsable_file(input_file_contents)

    reversed_file_contents = input_file_contents.reverse

    line_counter = 0

    if input_file_contents.join.include?("__END__")

      while !reversed_file_contents[line_counter].strip.include?("__END__")

        line_counter += 1

      end

      return_contents = input_file_contents[0...-1*line_counter-1]

    else

      input_file_contents

    end

  end

  def replace_multiline_comments(input_file_contents,nila_file_path,*output_js_file_path)

    #This method will replace both the single and multiline comments
    #
    #Single line comment will be replaced by => --single_line_comment[n]
    #
    #Multiline comment will be replaced by => --multiline_comment[n]

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def find_file_path(input_path,file_extension)

      extension_remover = input_path.split(file_extension)

      remaining_string = extension_remover[0].reverse

      path_finder = remaining_string.index("/")

      remaining_string = remaining_string.reverse

      return remaining_string[0...remaining_string.length-path_finder]

    end

    def find_file_name(input_path,file_extension)

      extension_remover = input_path.split(file_extension)

      remaining_string = extension_remover[0].reverse

      path_finder = remaining_string.index("/")

      remaining_string = remaining_string.reverse

      return remaining_string[remaining_string.length-path_finder..-1]

    end

    multiline_comments = []

    file_contents_as_string = input_file_contents.join

    modified_file_contents = file_contents_as_string.dup

    multiline_comment_counter = 1

    multiline_comments_start = find_all_matching_indices(file_contents_as_string,"=begin")

    multiline_comments_end = find_all_matching_indices(file_contents_as_string,"=end")

    for y in 0...multiline_comments_start.length

      start_of_multiline_comment = multiline_comments_start[y]

      end_of_multiline_comment = multiline_comments_end[y]

      multiline_comment = file_contents_as_string[start_of_multiline_comment..end_of_multiline_comment+3]

      modified_file_contents = modified_file_contents.gsub(multiline_comment,"--multiline_comment[#{multiline_comment_counter}]")

      multiline_comment_counter += 1

      multiline_comments << multiline_comment


    end

    temporary_nila_file = find_file_path(nila_file_path,".nila") + "temp_nila.nila"

    if output_js_file_path.empty?

      output_js_file = find_file_path(nila_file_path,".nila") + find_file_name(nila_file_path,".nila") + ".js"

    else

      output_js_file = output_js_file_path[0]

    end

    file_id = open(temporary_nila_file, 'w')

    file_id2 = open(output_js_file, 'w')

    file_id.write(modified_file_contents)

    file_id.close()

    file_id2.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    comments = multiline_comments.dup

    return line_by_line_contents,comments,temporary_nila_file,output_js_file

  end

  def split_semicolon_seperated_expressions(input_file_contents)

    modified_file_contents = input_file_contents.dup

    input_file_contents.each_with_index do |line,index|

      if line.include?("\"")

        first_index = line.index("\"")

        modified_line = line.sub(line[first_index..line.index("\"",first_index+1)],"--string")

      elsif line.include?("'")

        first_index = line.index("'")

        modified_line = line.sub(line[first_index..line.index("'",first_index+1)],"--string")

      else

        modified_line = line

      end

      if modified_line.include?(";")

        replacement_line = modified_file_contents[index]

        replacement_line = replacement_line.split(";").join("\n\n") + "\n"

        modified_file_contents[index] = replacement_line

      end

    end

    return modified_file_contents

  end

  def compile_interpolated_strings(input_file_contents)

    modified_file_contents = input_file_contents.dup

    input_file_contents.each_with_index do |line,index|

      if line.include?("\#{")

        interpolated_strings = line.scan(/\#{\S{1,}}/)

        interpolated_strings.each do |interpol|

          string_split = line.split(interpol)

          if string_split[1].eql?("\"\n")

            replacement_string = "\" + " + interpol[2...-1]

            modified_file_contents[index] = modified_file_contents[index].sub(interpol+"\"",replacement_string)

          elsif string_split[1].eql?("\")\n")

            replacement_string = "\" + " + interpol[2...-1]

            modified_file_contents[index] = modified_file_contents[index].sub(interpol+"\"",replacement_string)

          else

            replacement_string = "\" + " + interpol[2...-1] + " + \""

            modified_file_contents[index] = modified_file_contents[index].sub(interpol,replacement_string)

          end

        end

      end

    end

    return modified_file_contents

  end

  def replace_singleline_comments(input_file_contents)

    single_line_comments = []

    singleline_comment_counter = 1

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      if current_row.include?("#")

        comment_start = current_row.index("#")

        if current_row[comment_start+1] != "{"

          comment = current_row[comment_start..-1]

          single_line_comments << comment

          current_row = current_row.gsub(comment,"--single_line_comment[#{singleline_comment_counter}]")

          singleline_comment_counter += 1

        end

      end

      input_file_contents[x] = current_row

    end

    return input_file_contents,single_line_comments

  end

  def replace_named_functions(nila_file_contents,temporary_nila_file)

    def extract_array(input_array,start_index,end_index)

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

      elsif current_row.lstrip.include?("end\n") || current_row.include?("end")

        end_locations << x


      end


    end

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

      named_code_blocks << extract_array(final_modified_file_contents,top_most_level,matching_level)

      start_blocks.delete_at(top_most_level_index)

      end_blocks.delete(matching_level)

    end

    codeblock_counter = 1

    named_functions = named_code_blocks.dup

    nested_functions = []

    named_code_blocks.each do |codeblock|

      if joined_file_contents.include?(codeblock.join)

        joined_file_contents = joined_file_contents.sub(codeblock.join,"--named_function[#{codeblock_counter}]\n")

        codeblock_counter += 1

        nested_functions = nested_functions + [[]]

      else

        nested_functions[codeblock_counter-2] << codeblock

        named_functions.delete(codeblock)

      end

    end


    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents,named_functions,nested_functions


  end

  def compile_multiple_variable_initialization(input_file_contents,temporary_nila_file)

    possible_variable_lines = input_file_contents.reject {|element| !element.include?"="}

    possible_multiple_initialization = possible_variable_lines.reject {|element| !element.split("=")[0].include?","}

    multiple_initialization_index = []

    possible_multiple_initialization.each do |statement|

      location_array = input_file_contents.each_index.select { |index| input_file_contents[index] == statement}

      multiple_initialization_index << location_array[0]

    end

    modified_file_contents = input_file_contents.dup

    multiple_init_counter = 1

    possible_multiple_initialization.each_with_index do |line,index|

      line_split = line.split(" = ")

      right_side_variables = line_split[0].split(",")

      replacement_string = "multipleinit#{multiple_init_counter} = #{line_split[1]}\n\n"

      variable_string = ""

      right_side_variables.each_with_index do |variable,var_index|

        variable_string = variable_string + variable.rstrip + " = multipleinit#{multiple_init_counter}[#{var_index}]\n\n"

      end

      replacement_string = replacement_string + variable_string

      modified_file_contents[multiple_initialization_index[index]] = replacement_string

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(modified_file_contents.join)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def compile_default_values(input_file_contents,temporary_nila_file)

    #This method compiles default values present in functions. An example is provided below

    # def fill(container = "cup",liquid = "coffee")
    #   puts "Filling the #{container} with #{liquid}"
    # end

    def parse_default_values(input_function_definition)

      split1,split2 = input_function_definition.split("(")

      split2,split3 = split2.split(")")

      function_parameters = split2.split(",")

      default_value_parameters = function_parameters.reject {|element| !element.include?"="}

      replacement_parameters = []

      replacement_string = ""

      default_value_parameters.each do |paramvalue|

        param, value = paramvalue.split("=")

        replacement_parameters << param.lstrip.rstrip

        replacement_string = replacement_string + "\n" + "if (#{param.lstrip.rstrip} == null) {\n  #{paramvalue.lstrip.rstrip}\n}\n" +"\n"

      end

      return replacement_string,default_value_parameters,replacement_parameters

    end

    possible_default_values = input_file_contents.dup.reject {|element| !element.include?("def")}

    possible_default_values = possible_default_values.reject {|element| !element.include?("=")}

    if !possible_default_values.empty?

      possible_default_values.each do |line|

        current_line_index = input_file_contents.each_index.select {|index| input_file_contents[index] == line}.flatten[0]

        replacement_string,value_parameters,replacement_parameters = parse_default_values(line)

        modified_line = line.dup

        value_parameters.each_with_index do |val,index|

          modified_line = modified_line.sub(val,replacement_parameters[index])

        end

        input_file_contents[current_line_index] = modified_line

        input_file_contents[current_line_index + 1] = replacement_string

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(input_file_contents.join)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def get_variables(input_file_contents,temporary_nila_file)

    variables = []

    input_file_contents = input_file_contents.collect {|element| element.gsub("+=","plusequal")}

    input_file_contents = input_file_contents.collect {|element| element.gsub("-=","minusequal")}

    input_file_contents = input_file_contents.collect {|element| element.gsub("*=","multiequal")}

    input_file_contents = input_file_contents.collect {|element| element.gsub("/=","divequal")}

    input_file_contents = input_file_contents.collect {|element| element.gsub("%=","modequal")}

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      #The condition below verifies if the rows contain any equation operators.

      if current_row.include?("=") and !current_row.include?("def")

        current_row = current_row.rstrip + "\n"

        current_row_split = current_row.split("=")

        for y in 0...current_row_split.length

          current_row_split[y] = current_row_split[y].strip


        end

        variables << current_row_split[0]


      end

      input_file_contents[x] = current_row

    end

    file_contents_as_string = input_file_contents.join

    file_id = open(temporary_nila_file, 'w')

    file_id.write(file_contents_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    if variables.length > 0

      variable_declaration_string = "var " + variables.uniq.sort.join(", ") + "\n\n"

      line_by_line_contents = [variable_declaration_string,line_by_line_contents].flatten

    end

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("plusequal","+=")}

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("minusequal","-=")}

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("multiequal","*=")}

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("divequal","/=")}

    line_by_line_contents = line_by_line_contents.collect {|element| element.gsub("modequal","%=")}

    return variables.uniq,line_by_line_contents

  end

  def remove_question_marks(input_file_contents,variable_list,temporary_nila_file)

    #A method to remove question marks from global variable names. Local variables are dealt
    #with in their appropriate scope.

    #Params:
    #input_file_contents => An array containing the contents of the input nila file
    #variable_list => An array containing all the global variables declared in the file
    #temporary_nila_file => A file object used to write temporary contents

    #Example:

    #Nila
    #isprime? = false

    #Javascript Output
    #var isprime;
    #isprime = false;

    #Returns a modified input_file_contents with all the question marks removed

    joined_file_contents = input_file_contents.join

    variable_list.each do |var|

      if var.include? "?"

        joined_file_contents = joined_file_contents.gsub(var,var[0...-1])

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def compile_arrays(input_file_contents)

    #Currently the following kinds of array constructs are compilable

    # 1. %w{} syntax
    # 2. Range - Coming soon!

    def compile_w_arrays(input_file_contents)

      def extract(input_string,pattern_start,pattern_end)

        def find_all_matching_indices(input_string,pattern)

          locations = []

          index = input_string.index(pattern)

          while index != nil

            locations << index

            index = input_string.index(pattern,index+1)


          end

          return locations


        end

        all_start_locations = find_all_matching_indices(input_string,pattern_start)

        all_end_locations = find_all_matching_indices(input_string,pattern_end)

        pattern = []

        all_start_locations.each_with_index do |location,index|

          pattern << input_string[location..all_end_locations[index]]

        end

        return pattern

      end

      def compile_w_syntax(input_string)

        modified_input_string = input_string[3...-1]

        string_split = modified_input_string.split(" ")

        return string_split.to_s

      end

      modified_file_contents = input_file_contents.dup

      input_file_contents.each_with_index do |line,index|

        if line.include?("%w{")

          string_arrays = extract(line,"%w{","}")

          string_arrays.each do |array|

            modified_file_contents[index] = modified_file_contents[index].sub(array,compile_w_syntax(array))

          end

        end

      end

      return modified_file_contents

    end

    def compile_array_indexing(input_file_contents)

      possible_indexing_operation = input_file_contents.dup.reject {|element| !element.include?"[" and !element.include?"]"}

      possible_range_indexing = possible_indexing_operation.reject {|element| !element.include?".."}

      triple_range_indexing = possible_range_indexing.reject {|element| !element.include?"..."}

      triple_range_indexes = []

      triple_range_indexing.each do |line|

        triple_range_indexes << input_file_contents.dup.each_index.select {|index| input_file_contents[index] == line}

      end

      triple_range_indexes = triple_range_indexes.flatten

      triple_range_indexing.each_with_index do |line,index|

        split1,split2 = line.split("[")

        range_index,split3 = split2.split("]")

        index_start,index_end = range_index.split "..."

        replacement_string =  nil

        if index_end.strip == "end"

          replacement_string = split1 + ".slice(#{index_start},#{split}.length)\n"

        else

          replacement_string = split1 + ".slice(#{index_start},#{index_end})\n"

        end

        possible_range_indexing.delete(input_file_contents[triple_range_indexes[index]])

        possible_indexing_operation.delete(input_file_contents[triple_range_indexes[index]])

        input_file_contents[triple_range_indexes[index]] = replacement_string

      end

      double_range_indexing = possible_range_indexing.reject {|element| !element.include?("..")}

      double_range_indexes = []

      double_range_indexing.each do |line|

        double_range_indexes << input_file_contents.dup.each_index.select {|index| input_file_contents[index] == line}

      end

      double_range_indexes = double_range_indexes.flatten

      double_range_indexing.each_with_index do |line,index|

        split1,split2 = line.split("[")

        range_index,split3 = split2.split("]")

        index_start,index_end = range_index.split ".."

        index_start = "" if index_start.nil?

        index_end = "" if index_end.nil?

        replacement_string = nil

        if index_end.strip == "end"

          replacement_string = split1 + ".slice(#{index_start})\n"

        elsif index_end.strip == "" and index_start.strip == ""

          replacement_string = split1 + ".slice(0)\n"

        else

          replacement_string = split1 + ".slice(#{index_start},#{index_end}+1)\n"

        end

        possible_range_indexing.delete(input_file_contents[double_range_indexes[index]])

        possible_indexing_operation.delete(input_file_contents[double_range_indexes[index]])

        input_file_contents[double_range_indexes[index]] = replacement_string

      end

      duplicating_operations = input_file_contents.dup.reject{|element| !element.include?(".dup")}

      duplicating_operation_indexes = []

      duplicating_operations.each do |line|

        duplicating_operation_indexes << input_file_contents.dup.each_index.select {|index| input_file_contents[index] == line}

      end

      duplicating_operation_indexes = duplicating_operation_indexes.flatten

      duplicating_operation_indexes.each do |index|

        input_file_contents[index] = input_file_contents[index].sub(".dup",".slice(0)")

      end

      return input_file_contents

    end

    input_file_contents = compile_w_arrays(input_file_contents)

    input_file_contents = compile_array_indexing(input_file_contents)

    return input_file_contents


  end

  def compile_named_functions(input_file_contents,named_code_blocks,nested_functions,temporary_nila_file)

    #This method compiles all the named Nila functions. Below is an example of what is meant
    #by named/explicit function

    #def square(input_number)
    #
    #   input_number*input_number
    #
    #end

    #The above function will compile to

    #function square(input_number) {
    #
    #  return input_number*input_number;
    #
    # }

    def is_parameterless?(input_function_block)

      if input_function_block[0].include?("(")

        false

      else

        true

      end

    end

    def lexical_scoped_variables(input_function_block)

      #This method will pickup and declare all the variables inside a function block. In future, this method will be
      #merged with the get variables method

      controlregexp = /(if |while |def |function |function\()/

      variables = []

      function_name,parameters = input_function_block[0].split("(")

      parameters = parameters.split(")")[0].split(",")

      parameters = parameters.collect {|element| element.strip}

      input_function_block.each do |line|

        if line.include? "=" and line.index(controlregexp).nil?

          current_line_split = line.strip.split("=")

          variables << current_line_split[0].rstrip

        end

      end

      parameters.each do |param|

        if variables.include?(param)

          variables.delete(param)

        end

      end

      if variables.empty?

        return []

      else

        return variables.uniq

      end

    end

    def remove_question_marks(input_file_contents,input_list,temporary_nila_file)

      joined_file_contents = input_file_contents.join

      input_list.each do |element|

        if element.include? "?"

          joined_file_contents = joined_file_contents.gsub(element,element[0...-1])

        end

      end

      file_id = open(temporary_nila_file, 'w')

      file_id.write(joined_file_contents)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def add_auto_return_statement(input_array)

      joined_array = input_array.join

      reversed_input_array = input_array.reverse

      if !joined_array.include?("return ")

        rejected_array = reversed_input_array.reject {|content| content.lstrip.eql?("")}

        rejected_array = rejected_array[1..-1]

        if !rejected_array[0].strip.eql?("}")

          if !rejected_array[0].strip.eql?("end")

            last_statement = rejected_array[0]

            replacement_string = "return #{last_statement.lstrip}"

            input_array[input_array.index(last_statement)] = replacement_string

          end

        end

      end

      return input_array

    end

    def compile_multiple_return(input_array)

      def find_all_matching_indices(input_string,pattern)

        locations = []

        index = input_string.index(pattern)

        while index != nil

          locations << index

          index = input_string.index(pattern,index+1)


        end

        return locations


      end

      modified_input_array = input_array.dup

      return_statements = input_array.dup.reject {|element| !element.include?"return"}

      multiple_return_statements = return_statements.dup.reject {|element| !element.include?","}

      modified_multiple_return_statements = multiple_return_statements.dup

      return_statement_index = []

      multiple_return_statements.each do |statement|

        location_array = modified_input_array.each_index.select { |index| modified_input_array[index] == statement}

        return_statement_index << location_array[0]

      end

      multiple_return_statements.each_with_index do |return_statement,index|

        replacement_counter = 0

        if return_statement.include? "\""

          starting_quotes = find_all_matching_indices(return_statement,"\"")

          for x in 0...(starting_quotes.length)/2

            quotes = return_statement[starting_quotes[x]..starting_quotes[x+1]]

            replacement_counter += 1

            modified_multiple_return_statements[index] = modified_multiple_return_statements[index].sub(quotes,"repstring#{1}")

            modified_input_array[return_statement_index[index]] = modified_multiple_return_statements[index].sub(quotes,"repstring#{1}")

          end

        end

      end

      modified_multiple_return_statements = modified_multiple_return_statements.reject {|element| !element.include?","}

      return_statement_index = []

      modified_multiple_return_statements.each do |statement|

        location_array = modified_input_array.each_index.select { |index| modified_input_array[index] == statement}

        return_statement_index << location_array[0]

      end

      modified_multiple_return_statements.each_with_index do |return_statement,index|

        method_call_counter = 0

        if return_statement.include?"("

          open_paran_location = find_all_matching_indices(return_statement,"(")

          open_paran_location.each do |paran_index|

            method_call = return_statement[paran_index..return_statement.index(")",paran_index+1)]

            method_call_counter += 1

            modified_multiple_return_statements[index] = modified_multiple_return_statements[index].sub(method_call,"methodcall#{method_call_counter}")

            modified_input_array[return_statement_index[index]] = modified_multiple_return_statements[index].sub(method_call,"methodcall#{method_call_counter}")

          end

        end

      end

      modified_multiple_return_statements = modified_multiple_return_statements.reject {|element| !element.include?(",")}

      return_statement_index = []

      modified_multiple_return_statements.each do |statement|

        location_array = modified_input_array.each_index.select { |index| modified_input_array[index] == statement}

        return_statement_index << location_array[0]

      end

      return_statement_index.each do |index|

        original_statement = input_array[index]

        statement_split = original_statement.split("return ")

        replacement_split = "return [" + statement_split[1].rstrip + "]\n\n"

        input_array[index] = replacement_split

      end

      return input_array

    end

    def compile_function(input_array,temporary_nila_file)

      modified_input_array = input_array.dup

      if is_parameterless?(modified_input_array)

        if modified_input_array[0].include?("--single")

          modified_input_array[0] = input_array[0].sub "def","function"

          interim_string = modified_input_array[0].split("--single")

          modified_input_array[0] =  interim_string[0].rstrip + "() {\n--single" + interim_string[1]


        elsif modified_input_array[0].include?("--multi")

          modified_input_array[0] = input_array[0].sub "def","function"

          interim_string = modified_input_array[0].split("--multi")

          modified_input_array[0] =  interim_string[0].rstrip + "() {\n--multi" + interim_string[1]

        else

          modified_input_array[0] = input_array[0].sub "def","function"

          modified_input_array[0] = modified_input_array[0].rstrip + "() {\n"

        end

      else

        if modified_input_array[0].include?("--single")

          modified_input_array[0] = input_array[0].sub "def","function"

          interim_string = modified_input_array[0].split("--single")

          modified_input_array[0] =  interim_string[0].rstrip + " {\n--single" + interim_string[1]


        elsif modified_input_array[0].include?("--multi")

          modified_input_array[0] = input_array[0].sub "def","function"

          interim_string = modified_input_array[0].split("--multi")

          modified_input_array[0] =  interim_string[0].rstrip + " {\n--multi" + interim_string[1]

        else

          modified_input_array[0] = input_array[0].sub "def","function"

          modified_input_array[0] = modified_input_array[0].rstrip + " {\n"

        end

      end

      modified_input_array[-1] = input_array[-1].sub "end","}\n"

      modified_input_array = compile_multiple_variable_initialization(modified_input_array,temporary_nila_file)

      variables = lexical_scoped_variables(modified_input_array)

      if !variables.empty?

        variable_string = "\nvar " + variables.join(", ") + "\n"

        modified_input_array.insert(1,variable_string)

      end

      modified_input_array = remove_question_marks(modified_input_array,variables,temporary_nila_file)

      modified_input_array = add_auto_return_statement(modified_input_array)

      modified_input_array = compile_multiple_return(modified_input_array)

      return modified_input_array

    end

    def extract_function_name(input_code_block)

      first_line = input_code_block[0]

      first_line_split = first_line.split(" ")

      if first_line_split[1].include?("(")

        function_name,parameters = first_line_split[1].split("(")

      else

        function_name = first_line_split[1]

      end

      return function_name

    end

    joined_file_contents = input_file_contents.join

    codeblock_counter = 1

    function_names = []

    named_code_blocks.each do |codeblock|

      function_names[codeblock_counter-1] = []

      joined_file_contents = joined_file_contents.sub("--named_function[#{codeblock_counter}]\n",compile_function(codeblock,temporary_nila_file).join)

      codeblock_counter += 1

      current_nested_functions = nested_functions[codeblock_counter-2]

      function_names[codeblock_counter-2] << extract_function_name(codeblock)

      current_nested_functions.each do |nested_function|

        function_names[codeblock_counter-2] << extract_function_name(nested_function)

        joined_file_contents = joined_file_contents.sub(nested_function.join,compile_function(nested_function,temporary_nila_file).join)

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents,function_names

  end

  def compile_custom_function_map(input_file_contents)

    function_map_replacements = {

        "puts" => "console.log",

        "print" => "process.stdout.write"

    }

    function_map = function_map_replacements.keys

    modified_file_contents = input_file_contents.dup

    input_file_contents.each_with_index do |line,index|

      function_map.each do |function|

        if line.include?(function+"(") or line.include?(function+" ")

          modified_file_contents[index] = line.sub(function,function_map_replacements[function])

        end

      end

    end

    return modified_file_contents,function_map_replacements.values

  end

  def compile_whitespace_delimited_functions(input_file_contents,function_names,temporary_nila_file)

    def extract(input_string,pattern_start,pattern_end)

      def find_all_matching_indices(input_string,pattern)

        locations = []

        index = input_string.index(pattern)

        while index != nil

          locations << index

          index = input_string.index(pattern,index+1)


        end

        return locations


      end

      all_start_locations = find_all_matching_indices(input_string,pattern_start)

      pattern = []

      all_start_locations.each do |location|

        extracted_string = input_string[location..-1]

        pattern << extracted_string[0..extracted_string.index(pattern_end)]

      end

      return pattern

    end

    begin

      input_file_contents[-1] = input_file_contents[-1] + "\n" if !input_file_contents[-1].include?("\n")

      joined_file_contents = input_file_contents.join

      function_names.each do |list_of_functions|

        list_of_functions.each do |function|

          matching_strings = extract(joined_file_contents,function+" ","\n")

          matching_strings.each do |string|

            modified_string = string.dup

            modified_string = modified_string.sub(function+" ",function+"(")

            modified_string = modified_string.sub("\n",")\n")

            joined_file_contents = joined_file_contents.sub(string,modified_string)

          end

        end

      end

    rescue NoMethodError

      puts "Whitespace delimitation exited with errors!"

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def compile_conditional_structures(input_file_contents,temporary_nila_file)

    #Currently the following conditional structures have been implemented

    #1. If and While Inline Statements

    def compile_inline_conditionals(input_file_contents,temporary_nila_file)

      conditionals = [/( if )/,/( while )/,/( unless )/,/( until )/]

      plain_conditionals = [" if "," while "," unless "," until "]

      joined_file_contents = input_file_contents.join

      output_statement = ""

      conditionals.each_with_index do |regex,index|

        matching_lines = input_file_contents.reject {|content| content.index(regex).nil?}

        matching_lines.each do |line|

          line_split = line.split(plain_conditionals[index])

          if index == 0

            output_statement = "if (#{line_split[1].lstrip.rstrip.gsub("?","")}) {\n\n#{line_split[0]}\n}\n"

          elsif index == 1

            output_statement = "while (#{line_split[1].lstrip.rstrip.gsub("?","")}) {\n\n#{line_split[0]}\n}\n"

          elsif index == 2

            output_statement = "if (!(#{line_split[1].lstrip.rstrip.gsub("?","")})) {\n\n#{line_split[0]}\n}\n"

          elsif index == 3

            output_statement = "while (!(#{line_split[1].lstrip.rstrip.gsub("?","")})) {\n\n#{line_split[0]}\n}\n"

          end

          joined_file_contents = joined_file_contents.sub(line,output_statement)

        end

      end

      file_id = open(temporary_nila_file, 'w')

      file_id.write(joined_file_contents)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def compile_regular_if(input_file_contents,temporary_nila_file)

      def convert_string_to_array(input_string,temporary_nila_file)

        file_id = open(temporary_nila_file, 'w')

        file_id.write(input_string)

        file_id.close()

        line_by_line_contents = read_file_line_by_line(temporary_nila_file)

        return line_by_line_contents

      end

      def extract_if_blocks(if_statement_indexes,input_file_contents)

        possible_if_blocks = []

        if_block_counter = 0

        extracted_blocks = []

        controlregexp = /(if |while |def )/

        rejectionregexp = /( if | while )/

        for x in 0...if_statement_indexes.length-1

          possible_if_blocks << input_file_contents[if_statement_indexes[x]..if_statement_indexes[x+1]]

        end

        end_counter = 0

        end_index = []

        current_block = []

        possible_if_blocks.each_with_index do |block|

          current_block += block

          current_block.each_with_index do |line,index|

            if line.lstrip.eql? "end\n"

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

              current_block.each_with_index do |line,index|

                if line.lstrip.eql? "end\n"

                  end_counter += 1

                  end_index << index

                end

              end

            end

          end

        end

        return current_block,extracted_blocks

      end

      def compile_if_syntax(input_block)

        starting_line = input_block[0]

        starting_line = starting_line + "\n" if starting_line.lstrip == starting_line

        junk,condition = starting_line.split("if")

        input_block[0] = "Euuf (#{condition.lstrip.rstrip.gsub("?","")}) {\n"

        input_block[-1] = input_block[-1].lstrip.sub("end","}")

        elsif_statements = input_block.reject {|element| !element.include?("elsuf")}

        elsif_statements.each do |statement|

          junk,condition = statement.split("elsuf")

          input_block[input_block.index(statement)] = "} elsuf (#{condition.lstrip.rstrip.gsub("?","")}) {\n"

        end

        else_statements = input_block.reject {|element| !element.include?("else")}

        else_statements.each do |statement|

          input_block[input_block.index(statement)] = "} else {\n"

        end

        return input_block

      end

      input_file_contents = input_file_contents.collect {|element| element.sub("elsif","elsuf")}

      possible_if_statements = input_file_contents.reject {|element| !element.include?("if")}

      possible_if_statements = possible_if_statements.reject {|element| element.include?("else")}

      possible_if_statements = possible_if_statements.reject {|element| element.lstrip.include?(" if ")}

      if !possible_if_statements.empty?

        if_statement_indexes = []

        possible_if_statements.each do |statement|

          if_statement_indexes << input_file_contents.dup.each_index.select {|index| input_file_contents[index] == statement}

        end

        if_statement_indexes = if_statement_indexes.flatten + [-1]

        controlregexp = /(while |def )/

        modified_input_contents,extracted_statements = extract_if_blocks(if_statement_indexes,input_file_contents.clone)

        joined_blocks = extracted_statements.collect {|element| element.join}

        if_statements = joined_blocks.reject {|element| element.index(controlregexp) != nil}

        rejected_elements = joined_blocks - if_statements

        rejected_elements_index = []

        rejected_elements.each do |element|

          rejected_elements_index << joined_blocks.each_index.select {|index| joined_blocks[index] == element}

        end

        if_blocks_index = (0...extracted_statements.length).to_a

        rejected_elements_index = rejected_elements_index.flatten

        if_blocks_index -= rejected_elements_index

        modified_if_statements = if_statements.collect {|string| convert_string_to_array(string,temporary_nila_file)}

        modified_if_statements = modified_if_statements.collect {|block| compile_if_syntax(block)}.reverse

        if_blocks_index = if_blocks_index.collect {|element| "--ifblock#{element}"}.reverse

        rejected_elements_index = rejected_elements_index.collect {|element| "--ifblock#{element}"}.reverse

        rejected_elements = rejected_elements.reverse

        joined_file_contents = modified_input_contents.join

        until if_blocks_index.empty? and rejected_elements_index.empty?

          if !if_blocks_index.empty?

            if joined_file_contents.include?(if_blocks_index[0])

              joined_file_contents = joined_file_contents.sub(if_blocks_index[0],modified_if_statements[0].join)

              if_blocks_index.delete_at(0)

              modified_if_statements.delete_at(0)

            else

              joined_file_contents = joined_file_contents.sub(rejected_elements_index[0],rejected_elements[0])

              rejected_elements_index.delete_at(0)

              rejected_elements.delete_at(0)

            end

          else

            joined_file_contents = joined_file_contents.sub(rejected_elements_index[0],rejected_elements[0])

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

    file_contents = compile_regular_if(input_file_contents,temporary_nila_file)

    file_contents = compile_inline_conditionals(file_contents,temporary_nila_file)

    return file_contents

  end

  def compile_comments(input_file_contents,comments,temporary_nila_file)

    #This method converts Nila comments into pure Javascript comments. This method
    #handles both single line and multiline comments.

    file_contents_as_string = input_file_contents.join

    single_line_comments = comments[0]

    multiline_comments = comments[1]

    single_line_comment_counter = 1

    multi_line_comment_counter = 1

    for x in 0...single_line_comments.length

      current_singleline_comment = "--single_line_comment[#{single_line_comment_counter}]"

      replacement_singleline_string = single_line_comments[x].sub("#","//")

      file_contents_as_string = file_contents_as_string.sub(current_singleline_comment,replacement_singleline_string)

      single_line_comment_counter += 1


    end

    for y in 0...multiline_comments.length

      current_multiline_comment = "--multiline_comment[#{multi_line_comment_counter}]"

      replacement_multiline_string = multiline_comments[y].sub("=begin","/*\n")

      replacement_multiline_string = replacement_multiline_string.sub("=end","\n*/")

      file_contents_as_string = file_contents_as_string.sub(current_multiline_comment,replacement_multiline_string)

      multi_line_comment_counter += 1

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(file_contents_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    line_by_line_contents

  end

  def add_semicolons(input_file_contents)

    def comment(input_string)

      if input_string.include?("--single_line_comment")

        true

      elsif input_string.include?("--multiline_comment")

        true

      else

        false

      end

    end

    reject_regexp = /(function |if |else|switch |case|while |for )/

    modified_file_contents = []

    input_file_contents.each do |line|

      if line.index(reject_regexp) == nil

        if !comment(line)

          if !line.lstrip.eql?("")

            if !line.lstrip.eql?("}\n")

              if !line.lstrip.eql?("}\n\n")

                modified_file_contents << line.rstrip + ";\n\n"

              else

                modified_file_contents << line

              end

            else

              modified_file_contents << line

            end

          else

            modified_file_contents << line

          end

        else

          modified_file_contents << line

        end

      else

        modified_file_contents << line

      end

    end

    modified_file_contents

  end

  def pretty_print_javascript(javascript_file_contents,temporary_nila_file)

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

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def convert_string_to_array(input_string,temporary_nila_file)

      file_id = open(temporary_nila_file, 'w')

      file_id.write(input_string)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def previous_formatting(input_string,tab_counter,temporary_nila_file)

      string_as_array = convert_string_to_array(input_string,temporary_nila_file)

      modified_array = []

      string_as_array.each do |line|

        modified_array << "  "*tab_counter + line

      end

      return modified_array.join

    end

    def fix_newlines(file_contents)

      def extract_blocks(file_contents)

        javascript_regexp = /(if |while |function |function\()/

        block_starting_lines = file_contents.dup.reject { |element| element.index(javascript_regexp).nil?}[1..-1]

        block_starting_lines = block_starting_lines.reject { |element| element.include?("    ")}

        initial_starting_lines = block_starting_lines.dup

        starting_line_indices = []

        block_starting_lines.each do |line|

          starting_line_indices << file_contents.index(line)

        end

        block_ending_lines = file_contents.dup.each_index.select { |index| file_contents[index].eql? "  }\n" }

        modified_file_contents = file_contents.dup

        code_blocks = []

        starting_index = starting_line_indices[0]

        begin

        for x in 0...initial_starting_lines.length

          code_blocks << modified_file_contents[starting_index..block_ending_lines[0]]

          modified_file_contents[starting_index..block_ending_lines[0]] = []

          modified_file_contents.insert(starting_index,"  *****")

          block_starting_lines = modified_file_contents.dup.reject { |element| element.index(javascript_regexp).nil?}[1..-1]

          block_starting_lines = block_starting_lines.reject { |element| element.include?("    ")}

          starting_line_indices = []

          block_starting_lines.each do |line|

            starting_line_indices << modified_file_contents.index(line)

          end

          block_ending_lines = modified_file_contents.dup.each_index.select { |index| modified_file_contents[index].eql? "  }\n" }

          starting_index = starting_line_indices[0]

        end

        rescue TypeError

          puts "Whitespace was left unfixed!"

        rescue ArgumentError

          puts "Whitespace was left unfixed!"

        end

        return modified_file_contents,code_blocks

      end

      compact_contents = file_contents.reject {|element| element.lstrip.eql? ""}

      compact_contents,code_blocks = extract_blocks(compact_contents)

      processed_contents = compact_contents[1...-1].collect {|line| line+"\n"}

      compact_contents = [compact_contents[0]] + processed_contents + [compact_contents[-1]]

      code_block_locations = compact_contents.each_index.select { |index| compact_contents[index].eql? "  *****\n"}

      initial_locations = code_block_locations.dup

      starting_index = code_block_locations[0]

      for x in 0...initial_locations.length

        code_blocks[x][-1] = code_blocks[x][-1] + "\n"

        compact_contents = compact_contents[0...starting_index] + code_blocks[x] + compact_contents[starting_index+1..-1]

        code_block_locations = compact_contents.each_index.select { |index| compact_contents[index].eql? "  *****\n"}

        starting_index = code_block_locations[0]


      end

      return compact_contents

    end

    def roll_blocks(input_file_contents,code_block_starting_locations)

      if !code_block_starting_locations.empty?

        controlregexp = /(if |while |function |function\()/

        code_block_starting_locations = [0,code_block_starting_locations,-1].flatten

        possible_blocks = []

        block_counter = 0

        extracted_blocks = []

        for x in 0...code_block_starting_locations.length-1

          possible_blocks << input_file_contents[code_block_starting_locations[x]..code_block_starting_locations[x+1]]

        end

        end_counter = 0

        end_index = []

        current_block = []

        possible_blocks.each_with_index do |block|

          current_block += block

          current_block.each_with_index do |line,index|

            if line.lstrip.eql? "}\n"

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

              current_block[block_start..block_end] = "--block#{block_counter}"

              block_counter += 1

              end_counter = 0

              end_index = []

              current_block.each_with_index do |line,index|

                if line.lstrip.eql? "}\n"

                  end_counter += 1

                  end_index << index

                end

              end

            end

          end

        end

        return current_block,extracted_blocks

      else

        return input_file_contents,[]

      end

    end

    def fix_syntax_indentation(input_file_contents)

      fixableregexp = /(else |elsuf )/

      need_fixes = input_file_contents.reject {|line| line.index(fixableregexp).nil?}

      need_fixes.each do |fix|

        input_file_contents[input_file_contents.index(fix)] = input_file_contents[input_file_contents.index(fix)].sub("  ","")

      end

      return input_file_contents

    end

    javascript_regexp = /(if |while |function |function\()/

    javascript_file_contents = javascript_file_contents.collect {|element| element.sub("Euuf","if")}

    javascript_file_contents = reset_tabs(javascript_file_contents)

    starting_locations = []

    javascript_file_contents.each_with_index do |line,index|

      if line.index(javascript_regexp) != nil

        starting_locations << index

      end

    end

    remaining_file_contents,blocks = roll_blocks(javascript_file_contents,starting_locations)

    joined_file_contents = ""

    if !blocks.empty?

      remaining_file_contents = remaining_file_contents.collect {|element| "  " + element}

      main_blocks = remaining_file_contents.reject {|element| !element.include?("--block")}

      main_block_numbers = main_blocks.collect {|element| element.split("--block")[1]}

      modified_blocks = main_blocks.dup

      soft_tabs = "  "

      for x in (0...main_blocks.length)

        soft_tabs_counter = 1

        current_block = blocks[main_block_numbers[x].to_i]

        current_block = [soft_tabs + current_block[0]] + current_block[1...-1] + [soft_tabs*(soft_tabs_counter)+current_block[-1]]

        soft_tabs_counter += 1

        current_block = [current_block[0]] + current_block[1...-1].collect {|element| soft_tabs*(soft_tabs_counter)+element} + [current_block[-1]]

        nested_block = current_block.reject {|row| !row.include?("--block")}

        nested_block = nested_block.collect {|element| element.split("--block")[1]}

        nested_block = nested_block.collect {|element| element.rstrip.to_i}

        modified_nested_block = nested_block.clone

        current_block = current_block.join

        until modified_nested_block.empty?

          nested_block.each do |block_index|

            nested_block_contents = blocks[block_index]

            nested_block_contents = nested_block_contents[0...-1] + [soft_tabs*(soft_tabs_counter)+nested_block_contents[-1]]

            soft_tabs_counter += 1

            nested_block_contents = [nested_block_contents[0]] + nested_block_contents[1...-1].collect {|element| soft_tabs*(soft_tabs_counter)+element} + [nested_block_contents[-1]]

            nested_block_contents = nested_block_contents.reject {|element| element.gsub(" ","").eql?("")}

            current_block = current_block.sub("--block#{block_index}",nested_block_contents.join)

            blocks[block_index] = nested_block_contents

            modified_nested_block.delete_at(0)

            soft_tabs_counter -= 1

          end

          current_block = convert_string_to_array(current_block,temporary_nila_file)

          nested_block = current_block.reject {|element| !element.include?("--block")}

          nested_block = nested_block.collect {|element| element.split("--block")[1]}

          nested_block = nested_block.collect {|element| element.rstrip.to_i}

          modified_nested_block = nested_block.clone

          current_block = current_block.join

          if !nested_block.empty?

            soft_tabs_counter += 1

          end

        end

        modified_blocks[x] = current_block

      end



      remaining_file_contents = ["(function() {\n",remaining_file_contents,"\n}).call(this);"].flatten

      joined_file_contents = remaining_file_contents.join

      main_blocks.each_with_index do |block_id,index|

        joined_file_contents = joined_file_contents.sub(block_id,modified_blocks[index])

      end

    else

      remaining_file_contents = remaining_file_contents.collect {|element| "  " + element}

      remaining_file_contents = ["(function() {\n",remaining_file_contents,"\n}).call(this);"].flatten

      joined_file_contents = remaining_file_contents.join

    end


    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    line_by_line_contents = fix_newlines(line_by_line_contents)

    line_by_line_contents = fix_syntax_indentation(line_by_line_contents)

    return line_by_line_contents

  end

  def compile_operators(input_file_contents)

    input_file_contents = input_file_contents.collect {|element| element.sub(" and "," && ")}

    input_file_contents = input_file_contents.collect {|element| element.sub(" or "," || ")}

    input_file_contents = input_file_contents.collect {|element| element.sub("==","===")}

    input_file_contents = input_file_contents.collect {|element| element.sub("!=","!==")}

    input_file_contents = input_file_contents.collect {|element| element.sub("elsuf","else if")}

    return input_file_contents

  end

  def pretty_print_nila(input_file_contents)

    #Implementation is pending

  end

  def output_javascript(file_contents,output_file,temporary_nila_file)

    file_id = open(output_file, 'w')

    File.delete(temporary_nila_file)

    file_id.write("//Written using Nila. Visit http://adhithyan15.github.io/nila\n")

    file_id.write(file_contents.join)

    file_id.close()

  end

  if File.exist?(input_file_path)

    file_contents = read_file_line_by_line(input_file_path)

    file_contents = extract_parsable_file(file_contents)

    file_contents,multiline_comments,temp_file,output_js_file = replace_multiline_comments(file_contents,input_file_path,*output_file_name)

    file_contents,singleline_comments = replace_singleline_comments(file_contents)

    file_contents = split_semicolon_seperated_expressions(file_contents)

    file_contents = compile_interpolated_strings(file_contents)

    file_contents = compile_conditional_structures(file_contents,temp_file)

    file_contents = compile_arrays(file_contents)

    file_contents = compile_default_values(file_contents,temp_file)

    file_contents,named_functions,nested_functions = replace_named_functions(file_contents,temp_file)

    comments = [singleline_comments,multiline_comments]

    file_contents = compile_multiple_variable_initialization(file_contents,temp_file)

    list_of_variables,file_contents = get_variables(file_contents,temp_file)

    file_contents, function_names = compile_named_functions(file_contents,named_functions,nested_functions,temp_file)

    file_contents, ruby_functions = compile_custom_function_map(file_contents)

    function_names << ruby_functions

    file_contents = compile_whitespace_delimited_functions(file_contents,function_names,temp_file)

    file_contents = remove_question_marks(file_contents,list_of_variables,temp_file)

    file_contents = add_semicolons(file_contents)

    file_contents = compile_comments(file_contents,comments,temp_file)

    file_contents = pretty_print_javascript(file_contents,temp_file)

    file_contents = compile_operators(file_contents)

    output_javascript(file_contents,output_js_file,temp_file)

    puts "Compilation is successful!"

  else

    puts "File doesn't exist!"

  end

end

def create_mac_executable(input_file)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  mac_file_contents = ["#!/usr/bin/env ruby\n\n"] + read_file_line_by_line(input_file)

  mac_file_path = input_file.sub(".rb","")

  file_id = open(mac_file_path,"w")

  file_id.write(mac_file_contents.join)

  file_id.close

end

def find_file_name(input_path,file_extension)

  extension_remover = input_path.split(file_extension)

  remaining_string = extension_remover[0].reverse

  path_finder = remaining_string.index("/")

  remaining_string = remaining_string.reverse

  return remaining_string[remaining_string.length-path_finder..-1]

end

def find_file_path(input_path,file_extension)

  extension_remover = input_path.split(file_extension)

  remaining_string = extension_remover[0].reverse

  path_finder = remaining_string.index("/")

  remaining_string = remaining_string.reverse

  return remaining_string[0...remaining_string.length-path_finder]

end

nilac_version = "0.0.4.1"

opts = Slop.parse do
  on :c, :compile=, 'Compile Nila File', as:Array, delimiter:":"
  on :h, :help, 'Help With Nilac' do

    puts "Nilac is the official compiler for the Nila language.This is a basic help\nmessage with pointers to more information.\n\n"

    puts "  Basic Usage:\n\n"

    puts "    nilac -h/--help\n"

    puts "    nilac -v/--version\n"

    puts "    nilac [command] [file_options]\n\n"

    puts "  Available Commands:\n\n"

    puts "    nilac -c [nila_file] => Compile Nila File\n\n"

    puts "    nilac -c [nila_file]:[output_js_file] => Compile nila_file and saves it as\n    output_js_file\n\n"

    puts "    nilac -c [nila_file_folder] => Compiles each .nila file in the nila_folder\n\n"

    puts "    nilac -c [nila_file_folder]:[output_js_file_folder] => Compiles each .nila\n    file in the nila_folder and saves it in the output_js_file_folder\n\n"

    puts "    nilac -r [nila_file] => Compile and Run nila_file\n\n"

    puts "  Further Information:\n\n"

    puts "    Visit http://adhithyan15.github.io/nila to know more about the project."

  end
  on :v, :version, 'Output Nilac Version No' do

    puts nilac_version

  end
  on :r, :run=, 'Run Nila File', as:Array

  on :m, :buildmac, 'Build Nilac for Linux/Mac/Rubygems' do

    file_path = Dir.pwd + "/src/nilac.rb"

    create_mac_executable(file_path)

    puts "Build Successful!"

  end
end

opts = opts.to_hash

if opts[:compile] != nil

  if opts[:compile].length == 1

    input = opts[:compile][0]

    if input.include? ".nila"

      current_directory = Dir.pwd

      input_file = input

      file_path = current_directory + "/" + input_file

      compile(file_path)

    elsif input.include? "/"

      folder_path = input

      files = Dir.glob(File.join(folder_path, "*"))

      files = files.reject {|path| !path.include? ".nila"}

      files.each do |file|

        file_path = Dir.pwd + "/" + file

        compile(file_path)

      end

    end

  elsif opts[:compile].length == 2

    input = opts[:compile][0]

    output = opts[:compile][1]

    if input.include? ".nila" and output.include? ".js"

      input_file = input

      output_file = output

      input_file_path = input_file

      output_file_path = output_file

      compile(input_file_path,output_file_path)

    elsif input[-1].eql? "/" and output[-1].eql? "/"

      input_folder_path = input

      output_folder_path = output

      if !File.directory?(output_folder_path)

        FileUtils.mkdir_p(output_folder_path)

      end

      files = Dir.glob(File.join(input_folder_path, "*"))

      files = files.reject {|path| !path.include? ".nila"}

      files.each do |file|

        input_file_path = file

        output_file_path = output_folder_path + find_file_name(file,".nila") + ".js"

        compile(input_file_path,output_file_path)

      end

    end

  end

elsif opts[:run] != nil

  current_directory = Dir.pwd

  file = opts[:run][0]

  file_path = current_directory + "/" + file

  compile(file_path)

  js_file_name = find_file_path(file_path,".nila") + find_file_name(file_path,".nila") + ".js"

  node_output = `node #{js_file_name}`

  puts node_output

end
