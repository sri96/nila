def create_mac_executable(input_file)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  mac_file_contents = ["#!/usr/bin/env ruby\n\n"] + read_file_line_by_line(input_file)

  mac_file_path = input_file.sub(".rb", "")

  file_id = open(mac_file_path, "w")

  file_id.write(mac_file_contents.join)

  file_id.close

end
