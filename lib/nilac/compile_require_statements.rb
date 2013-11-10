require_relative 'replace_strings'

def compile_require_statements(input_file_contents)

 # This method automatically assigns variables to Node.js require statements
 #
 # Example:
 #
 # require 'fs'
 #
 # will compile to
 #
 # var fs = require('fs')

 modified_file_contents = input_file_contents.collect {|element| replace_strings(element)}

 possible_require_calls = modified_file_contents.reject {|element| !element.include?("require")}

 possible_require_calls.each do |statement|

   original_statement = input_file_contents[modified_file_contents.index(statement)]

   before,required_module = original_statement.split("require")

   unless before.include?("=")

     required_module = required_module.strip

     required_module = required_module[2...-2] if required_module.include?("(") and required_module.include?(")")

     required_module = required_module[1...-1] if required_module.include?("'")

     replacement_string = "#{required_module} = #{original_statement}"

     input_file_contents[modified_file_contents.index(statement)] = replacement_string

   end

 end

 return input_file_contents

end