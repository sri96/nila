require_relative 'read_file_line_by_line'
require_relative 'replace_strings'
  
  def compile_whitespace_delimited_functions(input_file_contents, function_names, temporary_nila_file)

    def extract(input_string, pattern_start, pattern_end)

      def find_all_matching_indices(input_string, pattern)

        locations = []

        index = input_string.index(pattern)

        while index != nil

          locations << index

          index = input_string.index(pattern, index+1)


        end

        return locations


      end

      all_start_locations = find_all_matching_indices(input_string, pattern_start)

      pattern = []

      all_start_locations.each do |location|

        extracted_string = input_string[location..-1]

        string_extract = extracted_string[0..extracted_string.index(pattern_end)]

        if !string_extract.include?(" = function(")

          pattern << string_extract

        end

      end

      return pattern

    end

    begin

      input_file_contents[-1] = input_file_contents[-1] + "\n" if !input_file_contents[-1].include?("\n")

      joined_file_contents = input_file_contents.join

      test_contents = replace_strings(joined_file_contents)

      function_names.each do |list_of_functions|

        list_of_functions.each do |function|

          if test_contents.include?(function)

            matching_strings = extract(joined_file_contents, function+" ", "\n")

            matching_strings.each do |string|

              modified_string = string.dup

              modified_string = modified_string.rstrip + modified_string.split(modified_string.rstrip)[1].gsub(" ", "")

              modified_string = modified_string.sub(function+" ", function+"(")

              modified_string = modified_string.split("#{function}(")[0] + "#{function}(" + modified_string.split("#{function}(")[1].lstrip

              modified_string = modified_string.sub("\n", ")\n")

              joined_file_contents = joined_file_contents.sub(string, modified_string)

            end

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