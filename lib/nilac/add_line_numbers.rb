def add_line_numbers(input_file_contents)

  line_counter = 1

  modified_file_contents = []

  input_file_contents.each do |element|

    modified_file_contents << "<<<#{line_counter}>>> " + element

    line_counter += 1

  end

  return modified_file_contents

end