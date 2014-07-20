require_relative 'replace_strings'

def compile_new_keyword(input_file_contents)

  # This construct compiles builtin Ruby type initializations to Javascript equivalents

  # Eg: String.new(somestring) => new String(somestring)

  match_hash = {

      "String.new" => "new String",

  }

  replaced_contents = input_file_contents.collect {|element| replace_strings(element)}

  matchables = match_hash.keys

  matched_values = match_hash.values

  matchables.each_with_index do |key,key_index|

    replaced_contents.each_with_index do |element,index|

      if element.include?(key)

        input_file_contents[index] = input_file_contents[index].gsub(key,matched_values[key_index])

      end

    end

  end

  return input_file_contents

end