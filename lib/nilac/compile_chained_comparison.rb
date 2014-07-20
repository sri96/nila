require_relative 'replace_strings'

def compile_chained_comparison(input_file_contents)

  select_regex = /\s?(=?[><]=?|==[=]?|&&|\|\|)/

  modified_file_contents = input_file_contents.collect {|element| replace_strings(element)}

  possible_comparisons = modified_file_contents.reject {|element| !element.index(select_regex)}

  possible_comparisons.each do |comparison|

    original_expression = comparison.dup

    comparison_split = comparison.split

    comparison_op_locations = comparison_split.each_index.select {|index| comparison_split[index].index(select_regex)}

    compared_expressions = []

    if comparison_op_locations.length > 1

      comparison_op_locations.each do |op_index|

        compared_expressions << [comparison_split[op_index-1],comparison_split[op_index], comparison_split[op_index+1]]

      end

    end



  end

end