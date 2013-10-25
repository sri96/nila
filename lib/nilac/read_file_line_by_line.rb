def read_file_line_by_line(input_path)

  file_id = open(input_path)

  file_line_by_line = file_id.readlines()

  file_id.close

  return file_line_by_line

end