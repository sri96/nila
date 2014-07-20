  require_relative "find_file_name"
	require_relative "find_file_path"
	require_relative "read_file_line_by_line"
	
	def replace_multiline_comments(input_file_contents, nila_file_path, *output_js_file_path)

    #This method will replace both the single and multiline comments
    #
    #Single line comment will be replaced by => --single_line_comment[n]
    #
    #Multiline comment will be replaced by => --multiline_comment[n]

    def find_all_matching_indices(input_string, pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern, index+1)


      end

      return locations


    end

    multiline_comments = []

    input_file_contents = input_file_contents.collect {|element| element.gsub(/=\s+begin\n/,"=begin")}

    input_file_contents = input_file_contents.collect {|element| element.gsub(/=\s+end\n/,"=end")}

    file_contents_as_string = input_file_contents.join

    modified_file_contents = file_contents_as_string.dup

    multiline_comment_counter = 1

    multiline_comments_start = find_all_matching_indices(file_contents_as_string, "=begin")

    multiline_comments_end = find_all_matching_indices(file_contents_as_string, "=end")

    for y in 0...multiline_comments_start.length

      start_of_multiline_comment = multiline_comments_start[y]

      end_of_multiline_comment = multiline_comments_end[y]

      multiline_comment = file_contents_as_string[start_of_multiline_comment..end_of_multiline_comment+3]

      modified_file_contents = modified_file_contents.gsub(multiline_comment, "--multiline_comment[#{multiline_comment_counter}]\n\n")

      multiline_comment_counter += 1

      multiline_comments << multiline_comment


    end

    temporary_nila_file = find_file_path(nila_file_path, ".nila") + "temp_nila.nila"

    if File.exist?(temporary_nila_file)

      File.delete(temporary_nila_file)

    end

    if output_js_file_path.empty?

      output_js_file = find_file_path(nila_file_path, ".nila") + find_file_name(nila_file_path, ".nila") + ".js"

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

    return line_by_line_contents, comments, temporary_nila_file, output_js_file

  end