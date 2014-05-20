  def compile_ruby_methods(input_file_contents)

    # These are some interesting methods that we really miss in Javascript.
    # So we have made these methods available

    def compile_complex_methods(input_file_contents)

      method_map_replacement = {

          ".include" => [".indexOf"," != -1"],

      }

      method_map_replacement.each do |val,key|

        possible_complex_method_calls = input_file_contents.reject {|element| !element.include?(val)}

        possible_complex_method_calls.each do |statement|

          before,after = statement.split(val)

          after,remains = after.split

          if after[-1].eql?(")")

            after = after[0...-1] + key[1] + after[-1]

          elsif after.strip.eql?(after)

            after = after + key[1]

          end

          reconstructed_statement = before + key[0] + after + remains

          input_file_contents[input_file_contents.index(statement)] = reconstructed_statement

        end

      end

      return input_file_contents

    end

    def compile_simple_parameter_taking_methods(input_file_contents)

      method_map_replacement = {

          ".index" => ".indexOf"

      }

      method_map = method_map_replacement.keys

      method_map_regex = method_map.collect {|name| name.gsub(".","\\.")}

      method_map_regex = Regexp.new(method_map_regex.join("|"))

      modified_file_contents = input_file_contents.clone

      input_file_contents.each_with_index do |line, index|

        if line.match(method_map_regex)

          method_match = line.match(method_map_regex).to_a[0]

          if line.include?(method_match + "(")

            line = line.gsub(method_match,method_map_replacement[method_match])

          end

        end

        modified_file_contents[index] = line

      end

      return modified_file_contents

    end

    method_map_replacement = {

        ".split" => ".split(\" \")",

        ".join" => ".join()",

        ".strip" => ".replace(/^\\s+|\\s+$/g,'')",

        ".lstrip" => ".replace(/^\\s+/g,\"\")",

        ".rstrip" => ".replace(/\\s+$/g,\"\")",

        ".to_s" => ".toString()",

        ".reverse" => ".reverse()",

        ".empty" => ".length == 0",

        ".upcase" => ".toUpperCase()",

        ".downcase" => ".toLowerCase()",

        ".zero?" => " === 0",

        ".eql" => " === ",

        ".next" => "++"


    }

    method_map = method_map_replacement.keys

    method_map_regex = method_map.collect {|name| name.gsub(".","\\.")}

    method_map_regex = Regexp.new(method_map_regex.join("|"))

    modified_file_contents = input_file_contents.clone

    input_file_contents.each_with_index do |line, index|

      if line.match(method_map_regex)

        method_match = line.match(method_map_regex).to_a[0]

        unless line.include?(method_match + "(")

          line = line.gsub(method_match,method_map_replacement[method_match])

        end

      end

      modified_file_contents[index] = line

    end

    modified_file_contents = compile_complex_methods(modified_file_contents)

    modified_file_contents = compile_simple_parameter_taking_methods(modified_file_contents)

    return modified_file_contents

  end