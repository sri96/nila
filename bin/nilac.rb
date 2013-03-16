#Nilac is the official Nila compiler. It compiles Nila into pure Javascript. Nilac is currently
#written in Ruby but will be self hosted in the upcoming years. Nila targets mostly the
#Node.js developers rather than client side developers.

#Nila was created by Adhithya Rajasekaran and Nilac is maintained by Adhithya Rajasekaran and Sri Madhavi Rajasekaran

require 'optparse' #Nilac uses optparse to parse command line options.

def compile(input_file_path)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  def replace_multiline_comments(input_file_contents,nila_file_path)

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

    output_js_file = find_file_path(nila_file_path,".nila") + find_file_name(nila_file_path,".nila") + ".js"

    file_id = open(temporary_nila_file, 'w')

    file_id2 = open(output_js_file, 'w')

    file_id.write(modified_file_contents)

    file_id2.write("//Written in Nila and compiled to Javascript. Have fun!\n\n")

    file_id.close()

    file_id2.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    comments = multiline_comments.dup

    return line_by_line_contents,comments,temporary_nila_file,output_js_file

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

      elsif current_row.include?("end\n") || current_row.include?("end")

        end_locations << x


      end


    end

    modified_file_contents = nila_file_contents.dup

    for y in 0...end_locations.length

      current_location = end_locations[y]

      current_string = modified_file_contents[current_location]

      finder_location = current_location

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

  def get_variables(input_file_contents,temporary_nila_file)

    #This method is solely focused on getting a list of variables to be declared.
    #Since Javascript is a dynamic language, Nila doesn't have to worry about following up on those variables.

    #Semicolons are required in Javascript for successful compilation. So this method adds semicolons at the end of each
    #variable usage statements.

    variables = []

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      #The condition below verifies if the rows contain any equation operators.

      if current_row.include?("=")

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

    variable_declaration_string = "var " + variables.uniq.join(", ") + "\n\n"

    line_by_line_contents = [variable_declaration_string,line_by_line_contents].flatten

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

  def compile_named_functions(input_file_contents,named_code_blocks,nested_functions,temporary_nila_file)

    #This method compiles all the named Nila functions. Below is an example of what is meant
    #by named/explicit function

    #def square(input_number)
    #
    #   return input_number*input_number
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

      variables = []

      input_function_block.each do |line|

        if line.include? "="

          current_line_split = line.strip.split("=")

          variables << current_line_split[0].rstrip

        end

      end

      variables.uniq

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

      variables = lexical_scoped_variables(modified_input_array)

      if !variables.empty?

        variable_string = "\nvar " + variables.join(", ") + "\n"

        modified_input_array.insert(1,variable_string)

      end

      modified_input_array = remove_question_marks(modified_input_array,variables,temporary_nila_file)

      return modified_input_array

    end

    joined_file_contents = input_file_contents.join

    codeblock_counter = 1

    named_code_blocks.each do |codeblock|

      joined_file_contents = joined_file_contents.sub("--named_function[#{codeblock_counter}]\n",compile_function(codeblock,temporary_nila_file).join)

      codeblock_counter += 1

      current_nested_functions = nested_functions[codeblock_counter-2]

      current_nested_functions.each do |nested_function|

        joined_file_contents = joined_file_contents.sub(nested_function.join,compile_function(nested_function,temporary_nila_file).join)

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents
    
  end

  def compile_custom_function_map(input_file_contents)

    function_map = ["puts"]

    function_map_replacements = {

        "puts" => "console.log"

    }

    modified_file_contents = input_file_contents.dup

    input_file_contents.each_with_index do |line,index|

      function_map.each do |function|

        if line.include?(function+"(") or line.include?(function+" ")

          modified_file_contents[index] = line.sub(function,function_map_replacements[function])

        end

      end

    end

    return modified_file_contents

  end

  def compile_conditional_structures(input_file_contents,temporary_nila_file)

    #Implementation is pending

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

          if !line.eql?("\n")

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

    javascript_regexp = /(function )/

    locations = []

    javascript_file_contents = reset_tabs(javascript_file_contents)

    joined_file_contents = javascript_file_contents.join

    code_block_starting_locations = find_all_matching_indices(joined_file_contents,javascript_regexp)

    code_block_ending_locations = find_all_matching_indices(joined_file_contents,"}")

    combined_location = [code_block_starting_locations,code_block_ending_locations.dup].flatten.sort

    last_matching_location = 0

    while code_block_ending_locations.length > 0

      matching_location = combined_location[combined_location.index(code_block_ending_locations[0])-1]

      location_among_start_locations = code_block_starting_locations.index(matching_location)

      locations << [[matching_location,combined_location[combined_location.index(code_block_ending_locations[0])]]]

      code_block_ending_locations.delete_at(0)

      if code_block_ending_locations.length > 0

        for x in location_among_start_locations-1..last_matching_location

          locations[-1] << [code_block_starting_locations[x],code_block_ending_locations[0]]

          code_block_ending_locations.delete_at(0)

        end

      end

      last_matching_location = location_among_start_locations + 1

    end

    modified_locations = []

    locations.each do |loc|

      modified_locations << loc.sort

    end

    modified_joined_file_contents = joined_file_contents.dup

    modified_locations.each do |location|

      soft_tabs_counter = 1

      location.each do |sublocation|

        string_extract = joined_file_contents[sublocation[0]..sublocation[1]]

        string_extract_array = convert_string_to_array(string_extract,temporary_nila_file)

        if soft_tabs_counter > 1

          string_extract_array[0] = "  "*(soft_tabs_counter-1) + string_extract_array[0]

          string_extract_array[-1] = "  "*(soft_tabs_counter-1) + string_extract_array[-1]

        end

        for x in 1...string_extract_array.length-1

          string_extract_array[x] = "  "*soft_tabs_counter + string_extract_array[x]

        end

        if soft_tabs_counter > 1

          modified_joined_file_contents = modified_joined_file_contents.sub(previous_formatting(string_extract,soft_tabs_counter-1,temporary_nila_file),string_extract_array.join)

        else

          modified_joined_file_contents = modified_joined_file_contents.sub(string_extract,string_extract_array.join)

        end

        soft_tabs_counter += 1

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(modified_joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  def output_javascript(file_contents,output_file,temporary_nila_file)

    file_id = open(output_file, 'w')

    File.delete(temporary_nila_file)

    file_id.write("//Written in Nila and compiled into Javascript.Have fun!\n\n")

    file_id.write("//Nila is written and maintained by Adhithya Rajasekaran and Sri Madhavi Rajasekaran!\n\n")

    file_id.write("//Visit http://adhithyan15.github.com/nila to know more!\n\n")

    file_id.write(file_contents.join)

    file_id.close()

  end

  file_contents = read_file_line_by_line(input_file_path)

  file_contents,multiline_comments,temp_file,output_js_file = replace_multiline_comments(file_contents,input_file_path)

  file_contents = compile_interpolated_strings(file_contents)

  file_contents,singleline_comments = replace_singleline_comments(file_contents)

  file_contents,named_functions,nested_functions = replace_named_functions(file_contents,temp_file)

  comments = [singleline_comments,multiline_comments]

  list_of_variables,file_contents = get_variables(file_contents,temp_file)

  file_contents = compile_named_functions(file_contents,named_functions,nested_functions,temp_file)

  file_contents = compile_custom_function_map(file_contents)

  file_contents = remove_question_marks(file_contents,list_of_variables,temp_file)

  file_contents = add_semicolons(file_contents)

  file_contents = compile_comments(file_contents,comments,temp_file)

  file_contents = pretty_print_javascript(file_contents,temp_file)

  output_javascript(file_contents,output_js_file,temp_file)


end

def create_executable(input_file)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  windows_output = `ocra --add-all-core #{input_file}`

end

def create_mac_executable(input_file)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  mac_file_contents = ["#!/usr/bin/env ruby"] + read_file_line_by_line(input_file)

  mac_file_path = input_file.sub(".rb","")

  file_id = open(mac_file_path,"w")

  file_id.write(mac_file_contents.join)

  file_id.close

end

def find_file_name(input_path,file_extension)

  extension_remover = input_path.split(file_extension)

  remaining_string = extension_remover[0].reverse

  path_finder = remaining_string.index("\\")

  remaining_string = remaining_string.reverse

  return remaining_string[remaining_string.length-path_finder..-1]

end

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: nilac [options] nilafile"

  opts.on("-c", "--compile FILE", "Compile to Javascript") do |file|
    current_directory = Dir.pwd
    file_path = current_directory + "/" + file
    compile(file_path)
    puts "Compilation Successful!"

  end

  opts.on("-r", "--run FILE", "Compile to Javascript and Run") do |file|
    current_directory = Dir.pwd

    file_path = current_directory + "/" + file

    compile(file_path)

    js_file_name = find_file_name(file_path,".nila") + ".js"

    node_output = `node #{js_file_name}`

    puts node_output

  end

  opts.on("-b", "--build FILE", "Builds Itself") do |file|

    file_path = Dir.pwd + "/nilac.rb"

    create_executable(file_path)

    puts "Build Successful!"

  end

  opts.on("-m", "--buildmac FILE", "Builds Mac Executables") do |macfile|

    file_path = Dir.pwd + "/nilac.rb"

    create_mac_executable(file_path)

    puts "Build Successful!"

  end

end.parse!
