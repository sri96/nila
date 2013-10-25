  def find_file_name(input_path, file_extension)

    extension_remover = input_path.split(file_extension)

    remaining_string = extension_remover[0].reverse

    path_finder = remaining_string.index("/")

    remaining_string = remaining_string.reverse

    return remaining_string[remaining_string.length-path_finder..-1]

  end