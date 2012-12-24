#Nilac is the official Nila compiler. It compiles Nila into pure Javascript. Nilac is currently
#written in Ruby but will be self hosted in the upcoming years. Nila targets mostly the
#Node.js developers rather than client side developers.

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

      path_finder = remaining_string.index("\\")

      remaining_string = remaining_string.reverse

      return remaining_string[0...remaining_string.length-path_finder]

    end

    def find_file_name(input_path,file_extension)

      extension_remover = input_path.split(file_extension)

      remaining_string = extension_remover[0].reverse

      path_finder = remaining_string.index("\\")

      remaining_string = remaining_string.reverse

      return remaining_string[remaining_string.length-path_finder..-1]

    end

    multiline_comments = []

    file_contents_as_string = input_file_contents.join

    modified_file_contents = file_contents_as_string.dup

    multiline_comment_counter = 1

    location_of_multiline_comments = find_all_matching_indices(file_contents_as_string,"###")

    for y in 0...(location_of_multiline_comments.length)/2

      start_of_multiline_comment = location_of_multiline_comments[y]

      end_of_multiline_comment = location_of_multiline_comments[y+1]

      multiline_comment = file_contents_as_string[start_of_multiline_comment..end_of_multiline_comment+2]

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

  def get_variables(input_file_contents)

    #This method is solely focused on getting a list of variables to be declared.
    #Since Javascript is a dynamic language, Nila doesn't have to worry about following up on those variables.

    variables = []

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      #The condition below verifies if the rows contain any equation operators.

      if current_row.include?("=")

        #In this block, the each row will be split using = sign and variables will be added to the
        #declared variables array

        current_row_split = current_row.split("=")

        #Extra spaces are stripped off from each of the elements that is produced after the splitting
        #operation

        #Each operator didn't work on the arrays. So I have to resort to for loop

        for y in 0...current_row_split.length

          current_row_split[y] = current_row_split[y].strip


        end

        variables << current_row_split[0]


      end


    end

    return variables.uniq


  end

  def compile_named_functions(input_file_contents,temporary_nila_file)

    #This method compiles all the named Nila functions. Below is an example of what is meant
    #by named/explicit function

    #def square(input_number)
    #
    #   return input_number*input_number
    #
    #end

    #Implementation is pending because Magnifique is a dependency.


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

      replacement_multiline_string = multiline_comments[y].sub("###","/*\n")

      replacement_multiline_string = replacement_multiline_string.sub("###","\n*/")

      file_contents_as_string = file_contents_as_string.sub(current_multiline_comment,replacement_multiline_string)

      multi_line_comment_counter += 1

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(file_contents_as_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end

  file_contents = read_file_line_by_line(input_file_path)

  file_contents,multiline_comments,temp_file,output_js_file = replace_multiline_comments(file_contents,input_file_path)

  file_contents,singleline_comments = replace_singleline_comments(file_contents)

  comments = [singleline_comments,multiline_comments]

  list_of_variables = get_variables(file_contents)

  variable_declaration_string = "var " + list_of_variables.join(",") + ";\n\n"

  file_contents = [variable_declaration_string,file_contents].flatten

  file_contents = compile_comments(file_contents,comments,temp_file)

  puts file_contents.join


end
