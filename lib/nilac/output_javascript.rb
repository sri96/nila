  def output_javascript(file_contents, output_file, temporary_nila_file)

    file_id = open(output_file, 'w')

    File.delete(temporary_nila_file)

    file_id.write("//Written using Nila. Visit http://adhithyan15.github.io/nila\n")

    file_id.write(file_contents.join)

    file_id.close()

  end