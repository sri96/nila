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

    reject_regexp = /(function |Euuf |if |else|elsuf|switch |case|while |whaaleskey |for )/

    modified_file_contents = input_file_contents.dup

    input_file_contents.each_with_index do |line,index|

      if line.index(reject_regexp) == nil

        if !comment(line)

          if !line.lstrip.eql?("")

            if !line.lstrip.eql?("}\n")

              if !line.lstrip.eql?("}\n\n")

                if line.rstrip[-1] != "[" and line.rstrip[-1] != "{" and line.rstrip[-1] != "," and line.rstrip[-1] != ";"

                  modified_file_contents[index] = line.rstrip + ";\n\n"

                end

              end

            end

          end

        end

      end

    end

    modified_file_contents

  end