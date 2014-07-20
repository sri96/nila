  def strToArray(input_string)

    file_id = File.new('hello.nila','w')

    file_id.write(input_string)

    file_id.close()

    line_by_line_contents = read_file_line_by_line('hello.nila')

    File.delete(file_id)

    return line_by_line_contents

  end