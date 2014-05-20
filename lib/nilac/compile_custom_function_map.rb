require_relative 'replace_strings'

def compile_custom_function_map(input_file_contents)

    function_map_replacements = {

        "puts" => "console.log",

        "p" => "console.log",

        "print" => "process.stdout.write",

        "require" => "require",

        "alert" => "alert",

        "prompt" => "prompt"

    }

    function_map = function_map_replacements.keys

    modified_file_contents = input_file_contents.dup

    javascript_regexp = /(if |for |while |\(function\(|= function\(|((=|:)\s+\{))/

    input_file_contents.each_with_index do |line, index|

      function_map.each do |function|

        include_comment = false

        test_line = replace_strings(line)

        if test_line.include?(function+"(") or test_line.include?(function+" ") and test_line.index(javascript_regexp) == nil

          testsplit =  line.gsub("#iggggnnnore","").split(function)

          testsplit = testsplit.collect {|element| element.strip}

          testsplit[0] = " " if testsplit[0].eql?("")

          if testsplit[1].include?("--single_line_comment")

            include_comment = true

          end

          if testsplit[0][-1].eql?(" ") or testsplit[0].eql?("return")

            if include_comment

              modified_line, comment = line.split("--single_line_comment")

              modified_file_contents[index] = modified_line.gsub(function, function_map_replacements[function])

              modified_file_contents[index] = modified_file_contents[index] + "--single_line_comment#{comment}"

            else

              modified_file_contents[index] = line.gsub(function, function_map_replacements[function])

            end

          end

        end

      end

    end

    return modified_file_contents, function_map_replacements.values

  end