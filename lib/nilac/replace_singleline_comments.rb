  require_relative 'replace_strings'
  require_relative 'extract_strings'
	
	def replace_singleline_comments(input_file_contents)
    
    single_line_comments = []

    singleline_comment_counter = 1

    modified_file_contents = input_file_contents.clone

    for x in 0...input_file_contents.length

      current_row = replace_strings(input_file_contents[x])

      if current_row.include?("#")

        current_row = modified_file_contents[x]

        current_row_strings = extract_strings(current_row)

        current_row = replace_strings(current_row)

        comment_start = current_row.index("#")

        if current_row[comment_start+1] != "{"

          comment = current_row[comment_start..-1]

          if comment.include?("--repstring")

            comment,string_id = comment.split("--repstring")

            comment = comment + current_row_strings[string_id.to_i]

          end

          single_line_comments << comment

          current_row_matches = current_row.scan(/--repstring\d+/).to_a

          current_row_matches.each_with_index do |element,index|

            junk,string_id = element.split("--repstring")

            current_row = current_row.gsub("--repstring#{string_id}",current_row_strings[index])

          end

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