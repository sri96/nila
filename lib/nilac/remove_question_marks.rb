require_relative 'read_file_line_by_line'
  
  def remove_question_marks(input_file_contents, variable_list, temporary_nila_file)

    #A method to remove question marks from global variable names. Local variables are dealt
    #with in their appropriate scope.

    #Params:
    #input_file_contents => An array containing the contents of the input nila file
    #variable_list => An array containing all the global variables declared in the file
    #temporary_nila_file => A file object used to write temporary contents

    #Example:

    #Nila
    #isprime? = false

    #Javascript Output
    #var isprime;
    #isprime = false;

    #Returns a modified input_file_contents with all the question marks removed

    joined_file_contents = input_file_contents.join

    variable_list.each do |var|

      if var.include? "?"

        joined_file_contents = joined_file_contents.gsub(var, var[0...-1])

      end

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end