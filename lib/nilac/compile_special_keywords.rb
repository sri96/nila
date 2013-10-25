require_relative 'replace_strings'
  
  def compile_special_keywords(input_file_contents)

    # This method compiles some Ruby specific keywords to Javascript to make it easy to port
    # Ruby code into Javascript
    
    keyword_replacement_map = {

        "nil" => "null",

        "Array.new" => "new Array()"

    }

    special_keywords = keyword_replacement_map.keys

    keyword_map_regex = special_keywords.collect {|name| name.gsub(".","\\.")}

    keyword_map_regex = Regexp.new(keyword_map_regex.join("|"))

    modified_file_contents = input_file_contents.clone

    input_file_contents.each_with_index do |line, index|

      if replace_strings(line).match(keyword_map_regex)

        method_match = line.match(keyword_map_regex).to_a[0]

        if line.split(keyword_map_regex)[0].include?("=")

          line = line.sub(method_match,keyword_replacement_map[method_match])

        end

      end

      modified_file_contents[index] = line

    end

    return modified_file_contents

  end