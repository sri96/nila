require_relative 'replace_strings'

# This method is one of our error modules that checks for syntax errors in the Repl input
# That's why this is in a separate file when compared to the full file checking functions

module ReplErrors

  def is_assignment_operation?(input_line)

    if replace_strings(input_line).include?("=")

      true

    else

      false

    end

  end

  def check_assignment_operation(input_line)

    # This line checks whether there are problems with assignment operation

    modified_string = replace_strings(input_line)

    if modified_string.split("=").length > 1

      return true,""

    else

      return false,"This is not a real assignment"

    end

  end

  def syntax_checklist(input_line)

    # This method is a checklist of all the steps that each line must go through to \
    # be error free

    proceed = false

    message = ""

    proceed = is_assignment_operation?(input_line)

    if proceed

      proceed,message = check_assignment_operation(input_line)

      if proceed

        proceed = true

      end

    end

    return proceed

  end

end
