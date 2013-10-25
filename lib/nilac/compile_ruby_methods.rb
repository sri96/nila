  def compile_ruby_methods(input_file_contents)

    # These are some interesting methods that we really miss in Javascript.
    # So we have made these methods available

    method_map_replacement = {

        ".split" => ".split(\" \")",

        ".join" => ".join()",

        ".strip" => ".replace(/^\\s+|\\s+$/g,'')",

        ".lstrip" => ".replace(/^\\s+/g,\"\")",

        ".rstrip" => ".replace(/\\s+$/g,\"\")",

        ".to_s" => ".toString()",

        ".reverse" => ".reverse()",

        ".empty?" => ".length == 0",

        ".upcase" => ".toUpperCase()",

        ".downcase" => ".toLowerCase()",

    }

    method_map = method_map_replacement.keys

    method_map_regex = method_map.collect {|name| name.gsub(".","\\.")}

    method_map_regex = Regexp.new(method_map_regex.join("|"))

    modified_file_contents = input_file_contents.clone

    input_file_contents.each_with_index do |line, index|

      if line.match(method_map_regex)

        method_match = line.match(method_map_regex).to_a[0]

        unless line.include?(method_match + "(")

          line = line.sub(method_match,method_map_replacement[method_match])

        end

      end

      modified_file_contents[index] = line

    end

    return modified_file_contents

  end