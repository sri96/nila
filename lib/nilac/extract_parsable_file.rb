def extract_parsable_file(input_file_contents)

  reversed_file_contents = input_file_contents.reverse

  line_counter = 0

  if input_file_contents.join.include?("__END__")

    while !reversed_file_contents[line_counter].strip.include?("__END__")

      line_counter += 1

    end

    return_contents = input_file_contents[0...-1*line_counter-1]

  else

    input_file_contents

  end

end
