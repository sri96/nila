  require_relative 'ErrorDeclarations'
	
	require_relative 'read_file_line_by_line'
	
	def compile_default_values(input_file_contents, temporary_nila_file)

    #This method compiles default values present in functions. An example is provided below

    # def fill(container = "cup",liquid = "coffee")
    #   puts "Filling the #{container} with #{liquid}"
    # end

    def errorFree(function_params)

      # This method checks for use cases in complex arguments where a default argument is used
      # after an optional argument. This will result in erroneous output. So this method will
      # stop it from happening.

      # Example:
      # def method_name(a,b,*c,d = 1,c,e)

      optional_param = function_params.reject {|element| !replace_strings(element).include?("*")}[0]

      unless optional_param.nil?

        after_splat = function_params[function_params.index(optional_param)+1..-1]

        if after_splat.reject {|element| !element.include?("=")}.empty?

          true

        else

          NilaSyntaxError.new("You cannot have default argument after an optional argument! Change the following usage!\n#{function_params.join(",")}")

        end

      else

        true

      end

    end

    def parse_default_values(input_function_definition)

      split1, split2 = input_function_definition.split("(")

      split2, split3 = split2.split(")")

      function_parameters = split2.split(",")

      if errorFree(function_parameters)

        default_value_parameters = function_parameters.reject { |element| !element.include? "=" }

        replacement_parameters = []

        replacement_string = ""

        default_value_parameters.each do |paramvalue|

          param, value = paramvalue.split("=")

          replacement_parameters << param.lstrip.rstrip

          replacement_string = replacement_string + "\n" + "if (#{param.lstrip.rstrip} equequ null) {\n  #{paramvalue.lstrip.rstrip}\n}\n" +"\n"

        end

        return replacement_string, default_value_parameters, replacement_parameters

      end

    end

    reject_regexp = /(function |Euuf |if |else|elsuf|switch |case|while |whaaleskey |for )/

    input_file_contents = input_file_contents.collect { |element| element.gsub("==", "equalequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("!=", "notequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("+=", "plusequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("-=", "minusequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("*=", "multiequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("/=", "divequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("%=", "modequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("=~", "matchequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub(">=", "greatequal") }

    input_file_contents = input_file_contents.collect { |element| element.gsub("<=", "lessyequal") }

    possible_default_values = input_file_contents.dup.reject { |element| (!element.include?("def")) }

    possible_default_values = possible_default_values.reject { |element| !element.include?("=") }

    possible_default_values = possible_default_values.reject {|element| !element.index(reject_regexp) == nil}

    if !possible_default_values.empty?

      possible_default_values.each do |line|

        current_line_index = input_file_contents.each_index.select { |index| input_file_contents[index] == line }.flatten[0]

        replacement_string, value_parameters, replacement_parameters = parse_default_values(line)

        modified_line = line.dup

        value_parameters.each_with_index do |val, index|

          modified_line = modified_line.sub(val, replacement_parameters[index])

        end

        input_file_contents[current_line_index] = modified_line

        input_file_contents.insert(current_line_index+1,replacement_string)

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(input_file_contents.join)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("plusequal", "+=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("minusequal", "-=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("multiequal", "*=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("divequal", "/=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("modequal", "%=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("equalequal", "==") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("notequal", "!=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("matchequal", "=~") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("greatequal", ">=") }

    line_by_line_contents = line_by_line_contents.collect { |element| element.gsub("lessyequal", "<=") }

    return line_by_line_contents

  end