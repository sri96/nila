  require_relative 'replace_strings'
	
	def replace_singleline_comments(input_file_contents)
    
    single_line_comments = []

    singleline_comment_counter = 1

    modified_file_contents = input_file_contents.clone

    for x in 0...input_file_contents.length

      current_row = replace_strings(input_file_contents[x])

      if current_row.include?("#")

        current_row = modified_file_contents[x]

        comment_start = current_row.index("#")

        if current_row[comment_start+1] != "{"

          comment = current_row[comment_start..-1]

          single_line_comments << comment

          current_row = current_row.gsub(comment, "--single_line_comment[#{singleline_comment_counter}]\n\n")

          singleline_comment_counter += 1

        end

      else

        current_row = modified_file_contents[x]

      end

      modified_file_contents[x] = current_row

    end

    return modified_file_contents, single_line_comments

  end