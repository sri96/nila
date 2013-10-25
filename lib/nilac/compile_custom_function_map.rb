  def compile_custom_function_map(input_file_contents)

    function_map_replacements = {

        "puts" => "console.log",

        "p" => "console.log",

        "print" => "process.stdout.write",

    }

    function_map = function_map_replacements.keys

    modified_file_contents = input_file_contents.dup

    javascript_regexp = /(if |for |while |\(function\(|= function\(|((=|:)\s+\{))/

    input_file_contents.each_with_index do |line, index|

      function_map.each do |function|

        if line.include?(function+"(") or line.include?(function+" ") and line.index(javascript_regexp) == nil

          testsplit =  line.split(function)

          testsplit = testsplit.collect {|element| element.strip}

          testsplit[0] = " " if testsplit[0].eql?("")

          if testsplit[0][-1].eql?(" ") or testsplit[0].eql?("return")

            modified_file_contents[index] = line.sub(function, function_map_replacements[function])

          end

        end

      end

    end

    return modified_file_contents, function_map_replacements.values

  end