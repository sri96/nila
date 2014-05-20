def compile_ranges(input_file_contents)

  # Currently, no implementation of Ranges exist for Nila. So we will be slowly developing one.
  # In Ruby, Ranges are a separate entity and are not part of Arrays. Nila will take a similar approach to Ranges.

  # In this section, we are introducing two Scala keywords to make range declaration more descriptive.
  # The two new keywords are *to* and *until*

  # Example:

  # [1 to 5] is equivalent to [1..5]
  # [1 until 5] is equivalent to [1...5]

  triple_ranges = input_file_contents.reject {|element| !element.index(/(\d+\s*until\s*\d+|last)/)}

  triple_ranges = triple_ranges.reject {|element| element.index(/(\d+\s*\.\.\.\s*\d+|last)/)}

  triple_ranges.each do |line|

    line_index = input_file_contents.index(line)

    range_extracts = line.scan(/(\d+\s*until\s*\d+|last)/).to_a

    range_extracts.each do |range|

      begin_num,end_num = range[0].split("until").collect {|element| element.strip}

      replacement_string = "#{begin_num}...#{end_num}"

      input_file_contents[line_index] = input_file_contents[line_index].sub(range[0],replacement_string)

    end

  end

  double_ranges = input_file_contents.reject {|element| !element.index(/(\d+\s*to\s*\d+|last)/)}

  double_ranges = double_ranges.reject {|element| element.index(/(\d+\s*\.\.\s*\d+|last)/)}

  double_ranges.each do |line|

    line_index = input_file_contents.index(line)

    range_extracts = line.scan(/(\d+\s*to\s*\d+|last)/).to_a

    range_extracts.each do |range|

      begin_num,end_num = range[0].split("to").collect {|element| element.strip}

      replacement_string = "#{begin_num}..#{end_num}"

      input_file_contents[line_index] = input_file_contents[line_index].sub(range[0],replacement_string)

    end

  end

  return input_file_contents

end