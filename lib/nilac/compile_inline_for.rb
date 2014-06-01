require_relative 'replace_strings'

def compile_inline_for(input_file_contents)

  test_regex = /( for )/

  possible_inline_for = input_file_contents.reject {|element| element.index(test_regex).nil?}

  possible_inline_for = possible_inline_for.reject {|element| element.rstrip.lstrip.index(test_regex).nil?}



end
