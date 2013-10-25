  def compile_integers(input_file_contents)

    modified_file_contents = input_file_contents.clone

    input_file_contents.each_with_index do |line,index|

      matches = line.scan(/(([0-9]+_)+([0-9]+|$))/)

      unless matches.empty?

        matches.each do |match_arr|

            modified_file_contents[index] = modified_file_contents[index].sub(match_arr[0],match_arr[0].gsub("_",""))

        end

      end

    end

    return modified_file_contents

  end