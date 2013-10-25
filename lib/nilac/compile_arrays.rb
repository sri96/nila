require_relative 'find_all_matching_indices'

require_relative 'read_file_line_by_line'

  def compile_arrays(input_file_contents, named_functions, temporary_nila_file)

    def compile_w_arrays(input_file_contents)

      def extract(input_string, pattern_start, pattern_end)
        
        all_start_locations = find_all_matching_indices(input_string, pattern_start)

        all_end_locations = find_all_matching_indices(input_string, pattern_end)

        pattern = []

        all_start_locations.each_with_index do |location, index|

          pattern << input_string[location..all_end_locations[index]]

        end

        return pattern

      end

      def compile_w_syntax(input_string)

        modified_input_string = input_string[3...-1]

        string_split = modified_input_string.split(" ")

        return string_split.to_s

      end

      modified_file_contents = input_file_contents.dup

      input_file_contents.each_with_index do |line, index|

        if line.include?("%w{")

          string_arrays = extract(line, "%w{", "}")

          string_arrays.each do |array|

            modified_file_contents[index] = modified_file_contents[index].sub(array, compile_w_syntax(array))

          end

        end

      end

      return modified_file_contents

    end

    def compile_array_indexing(input_file_contents)

      possible_indexing_operation = input_file_contents.dup.reject { |element| !element.include? "[" and !element.include? "]" }

      possible_range_indexing = possible_indexing_operation.reject { |element| !element.include? ".." }

      triple_range_indexing = possible_range_indexing.reject { |element| !element.include? "..." }

      triple_range_indexes = []

      triple_range_indexing.each do |line|

        triple_range_indexes << input_file_contents.dup.each_index.select { |index| input_file_contents[index] == line }

      end

      triple_range_indexes = triple_range_indexes.flatten

      triple_range_indexing.each_with_index do |line, index|

        split1, split2 = line.split("[")

        range_index, split3 = split2.split("]")

        index_start, index_end = range_index.split "..."

        replacement_string = nil

        if index_end.strip == "last"

          replacement_string = split1 + ".slice(#{index_start},#{split}.length)\n"

        else

          replacement_string = split1 + ".slice(#{index_start},#{index_end})\n"

        end

        possible_range_indexing.delete(input_file_contents[triple_range_indexes[index]])

        possible_indexing_operation.delete(input_file_contents[triple_range_indexes[index]])

        input_file_contents[triple_range_indexes[index]] = replacement_string

      end

      double_range_indexing = possible_range_indexing.reject { |element| !element.include?("..") }

      double_range_indexes = []

      double_range_indexing.each do |line|

        double_range_indexes << input_file_contents.dup.each_index.select { |index| input_file_contents[index] == line }

      end

      double_range_indexes = double_range_indexes.flatten
      
      double_range_indexing.each_with_index do |line, index|

        split1, split2 = line.split("[")

        range_index, split3 = split2.split("]")

        index_start, index_end = range_index.split ".."

        index_start = "" if index_start.nil?

        index_end = "" if index_end.nil?
          
        split3 = "" if split3.nil?

        replacement_string = nil

        if index_end.strip == "last"

          replacement_string = split1 + ".slice(#{index_start})" + split3.strip + "\n\n"

        elsif index_end.strip == "" and index_start.strip == ""

          replacement_string = split1 + ".slice(0)\n"

        else

          replacement_string = split1 + ".slice(#{index_start},#{index_end}+1)\n"

        end

        possible_range_indexing.delete(input_file_contents[double_range_indexes[index]])

        possible_indexing_operation.delete(input_file_contents[double_range_indexes[index]])

        input_file_contents[double_range_indexes[index]] = replacement_string

      end

      duplicating_operations = input_file_contents.dup.reject { |element| !element.include?(".dup") }

      duplicating_operation_indexes = []

      duplicating_operations.each do |line|

        duplicating_operation_indexes << input_file_contents.dup.each_index.select { |index| input_file_contents[index] == line }

      end

      duplicating_operation_indexes = duplicating_operation_indexes.flatten

      duplicating_operation_indexes.each do |index|

        input_file_contents[index] = input_file_contents[index].sub(".dup", ".slice(0)")

      end

      return input_file_contents

    end

    def compile_multiline(input_file_contents, temporary_nila_file)

      possible_arrays = input_file_contents.reject { |element| !element.include?("[") }

      possible_multiline_arrays = possible_arrays.reject { |element| element.include?("]") }

      multiline_arrays = []

      possible_multiline_arrays.each do |starting_line|

        index = input_file_contents.index(starting_line)

        line = starting_line

        until line.include?("]")

          index += 1

          line = input_file_contents[index]

        end

        multiline_arrays << input_file_contents[input_file_contents.index(starting_line)..index]

      end

      joined_file_contents = input_file_contents.join

      multiline_arrays.each do |array|

        modified_array = array.join

        array_extract = modified_array[modified_array.index("[")..modified_array.index("]")]

        array_contents = array_extract.split("[")[1].split("]")[0].lstrip.rstrip.split(",").collect { |element| element.lstrip.rstrip }

        array_contents = "[" + array_contents.join(",") + "]"

        joined_file_contents = joined_file_contents.sub(array_extract, array_contents)

      end

      file_id = open(temporary_nila_file, 'w')

      file_id.write(joined_file_contents)

      file_id.close()

      line_by_line_contents = read_file_line_by_line(temporary_nila_file)

      return line_by_line_contents

    end

    def compile_array_operators(input_file_contents)

      possible_operator_usage = input_file_contents.reject { |element| !element.include?("<<") }

      possible_operator_usage.each do |usage|

        left, right = usage.split("<<")

        input_file_contents[input_file_contents.index(usage)] = left.rstrip + ".push(#{right.strip})\n\n"

      end

      return input_file_contents

    end

    input_file_contents = compile_w_arrays(input_file_contents)

    input_file_contents = compile_array_indexing(input_file_contents)

    input_file_contents = compile_multiline(input_file_contents, temporary_nila_file)

    input_file_contents = compile_array_operators(input_file_contents)

    named_functions = named_functions.collect {|func| compile_w_arrays(func)}

    named_functions = named_functions.collect { |func| compile_array_indexing(func)}

    named_functions = named_functions.collect {|func| compile_multiline(func, temporary_nila_file)}

    named_functions = named_functions.collect {|func| compile_array_operators(func)}

    return input_file_contents, named_functions


  end