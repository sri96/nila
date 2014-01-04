require_relative 'replace_strings'
require_relative 'find_all_matching_indices'

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

    #compile_integer_methods(modified_file_contents)

    return modified_file_contents

end

def compile_integer_methods(input_file_contents)

  # These methods replace Javascript's parseInt method because it can produce erroneous output when called
  # without using a radix parameter

  def compile_dec_method(input_calls,file_contents)

    input_calls.each do |call|

      modified_call = call.dup

      if modified_call.include?("(") and modified_call.include?(")")

        parseint_statements = []

        counter = 0

        while modified_call.include?(".dec")

          modified_call = modified_call.sub(".dec",".bussssss")

          modified_call = modified_call.gsub(".dec",".greppppplin")

          modified_call = modified_call.sub(".bussssss",".dec ")

          string_extract = modified_call.reverse

          paranthesis_extract = [""]

          two_paranthesis = ""

          open_paran_index = nil

          offset_value = nil

          while string_extract.include?("(")

            open_paran_index = string_extract.index("(")

            test_extract = string_extract[0..open_paran_index].reverse

            two_paranthesis = test_extract[0..test_extract.index(")")]

            previous_value = paranthesis_extract[-1]

            if previous_value.length > two_paranthesis.length-(two_paranthesis.count("$@"))/2

              offset_value = previous_value

            end

            paranthesis_extract << two_paranthesis.sub("$@"*previous_value.length,previous_value)

            string_extract = string_extract.sub(two_paranthesis.reverse,"@$"*paranthesis_extract[-1].length)

          end

          #puts paranthesis_extract.to_s

          unless offset_value.nil?

            paranthesis_extract = paranthesis_extract.collect {|element| element.sub("$@"*offset_value.length,offset_value)}

          end

          full_call = paranthesis_extract.reject {|element| !element.include?(".dec ")}

          if full_call[0].include?(" .dec") or full_call[0].include?(").dec")

            correct_call = paranthesis_extract[paranthesis_extract.index(full_call[0])-1]

          else

            incomplete_call = paranthesis_extract[paranthesis_extract.index(full_call[0])-1]

            correct_call = modified_call[modified_call.index(incomplete_call)...modified_call.index(".dec")]

          end

          replacement_string = "parseInt(#{correct_call},10)"

          parseint_statements << replacement_string

          modified_call = modified_call.sub("#{correct_call}.dec","--parsesssInt{#{parseint_statements.index(replacement_string)}}")

          modified_call = modified_call.gsub(".greppppplin",".dec")

        end

        parseint_statements.each_with_index do |statement,index|

          modified_call = modified_call.sub("--parsesssInt{#{index}}",statement)

        end

        file_contents[file_contents.index(call)] = modified_call

      elsif modified_call.index(/("[\s\D]*\w{1,}*[\s\-@%\$\^\|:;&\(\)#!~\.\,`'_=\+<>\?\/\\\{\}\w{1,}]*".dec)/)

        select_regex = /("[\s\D]*\w{1,}*[\s\-@%\$\^\|:;&\(\)#!~\.\,`'_=\+<>\?\/\\\{\}\w{1,}]*".dec\s)/

        while modified_call.include?(".dec")

          # Our regex is not complex enough to extract the multitude of possibilities of .dec calls. So we are
          # using a small trick to allow it to select all the .dec calls by adding a space next to it.

          modified_call = modified_call.sub(".dec",".busssssss ")

          modified_call = modified_call.gsub(/.dec\s*/,".dec")

          modified_call = modified_call.sub(".busssssss ",".dec ")

          call_extract = modified_call.scan(select_regex)

          replacement_string = "parseInt(#{call_extract[0][0].strip.sub(".dec","")},10)"

          modified_call = modified_call.sub("#{call_extract[0][0]}",replacement_string)

        end

        file_contents[file_contents.index(call)] = modified_call

      #elsif modified_call.index()

      end

    end

    return file_contents

  end

  possible_dec_calls = input_file_contents.reject {|element| !replace_strings(element).include?(".dec")}

  modified_file_contents = compile_dec_method(possible_dec_calls,input_file_contents)

  return modified_file_contents

end