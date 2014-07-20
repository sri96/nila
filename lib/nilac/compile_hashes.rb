require_relative 'replace_strings'

require_relative 'read_file_line_by_line'
  
  def compile_hashes(input_file_contents,temporary_nila_file)

    def compile_multiline_hashes(input_file_contents,temporary_nila_file)
      
      javascript_regexp = /(if |while |for |function |function\()/

      modified_file_contents = input_file_contents.clone

      input_file_contents = input_file_contents.collect {|line| replace_strings(line)}

      possible_hashes = input_file_contents.reject { |element| !element.include?("{") }

      possible_hashes = possible_hashes.reject {|element| element.include?("loop")}

      possible_multiline_hashes = possible_hashes.reject { |element| element.include?("}") }

      possible_multiline_hashes = possible_multiline_hashes.reject {|element| element.index(javascript_regexp) != nil}

      multiline_hashes = []

      possible_multiline_hashes.each do |starting_line|

        index = input_file_contents.index(starting_line)

        line = modified_file_contents[index]

        until line.include?("}\n")

          index += 1

          line = modified_file_contents[index]

        end

        multiline_hashes << modified_file_contents[input_file_contents.index(starting_line)..index]

      end

      joined_file_contents = modified_file_contents.join

      multiline_hashes.each do |hash|

        modified_hash = hash.join

        hash_extract = modified_hash[modified_hash.index("{")..modified_hash.index("}")]

        hash_contents = hash_extract.split("{")[1].split("}")[0].lstrip.rstrip.split(",").collect { |element| element.lstrip.rstrip }

        hash_contents = "{" + hash_contents.join(",") + "}"

        joined_file_contents = joined_file_contents.sub(hash_extract, hash_contents)

      end

      file_id = open(temporary_nila_file, 'w')

      file_id.write(joined_file_contents)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def compile_inline_hashes(input_file_contents)

      javascript_regexp = /(if |while |for |function |function\(|%[qQw]*\{|lambda\s*\{|\s*->\s*\{|loop\s*)/

      modified_file_contents = input_file_contents.clone.collect {|element| replace_strings(element)}

      possible_inline_hashes = modified_file_contents.reject {|element| element.count("{") != 1}

      possible_inline_hashes = possible_inline_hashes.reject {|element| element.count("}") != 1}

      possible_inline_hashes = possible_inline_hashes.reject {|element| element.index(javascript_regexp) != nil}

      possible_inline_hashes = possible_inline_hashes.reject {|element| element.include?("{}")}

      possible_inline_hashes.each do |hash|

        hash = input_file_contents[modified_file_contents.index(hash)]

        hash_extract = hash[hash.index("{")..hash.index("}")]

        contents = hash_extract[1...-1].split(",")

        hash_contents = []

        contents.each do |items|

          items = items.lstrip.sub(":","") if items.lstrip[0] == ":"

          key, value = items.split("=>").collect {|element| element.lstrip.rstrip} if items.include?("=>")

          key, value = items.split(":").collect {|element| element.lstrip.rstrip} if items.include?(":")

          key = key.gsub("'","").gsub("\"","")

          hash_contents << "  #{key}: #{value},"

        end

        replacement_string = "{\n" + hash_contents.join("\n") + "\n};\n"

        input_file_contents[input_file_contents.index(hash)] = input_file_contents[input_file_contents.index(hash)].sub(hash_extract,replacement_string)

      end

      return input_file_contents

    end

    file_contents = compile_multiline_hashes(input_file_contents,temporary_nila_file)

    file_contents = compile_inline_hashes(file_contents)

    return file_contents

  end