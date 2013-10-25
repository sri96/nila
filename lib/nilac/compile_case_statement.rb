require_relative 'replace_strings'

require_relative 'read_file_line_by_line'
  
  def compile_case_statement(input_file_contents,temporary_nila_file)

    # This method compiles simple Ruby style case statements to Javascript
    # equivalent switch case statements

    # For an example, look at shark/test_files/case.nila

    def compile_when_statement(input_block)

      condition,body = input_block[0],input_block[1..-1]

      if replace_strings(condition.split("when ")[1]).include?(",")

        condition_cases = condition.split("when ")[1].split(",").collect {|element| element.strip}

        case_replacement = []

        condition_cases.each do |ccase|

          case_replacement << "case #{ccase}:%$%$ {\n\n"

          case_replacement << body.collect {|element| "  " + element.strip + "\n\n"}

          case_replacement << "  break\n%$%$\n}\n"

        end

      else

        case_replacement = []

        condition_case = condition.split("when ")[1].strip

        case_replacement << "case #{condition_case}:%$%$ {\n\n"

        case_replacement << body.collect {|element| "  " + element.strip + "\n\n"}

        case_replacement << "  break\n%$%$\n}\n"

      end

      return case_replacement.join

    end

    modified_file_contents = input_file_contents.clone

    possible_case_statements = input_file_contents.reject {|element| !element.include?("case ")}

    case_statements = []

    possible_case_statements.each do |statement|

      starting_index = input_file_contents.index(statement)

      index = starting_index

      until input_file_contents[index].strip.eql?("end")

        index += 1

      end

      case_statements << input_file_contents[starting_index..index].collect {|element| element.clone}.clone

    end

    legacy = case_statements.collect {|element| element.clone}

    replacement_strings = []

    case_statements.each do |statement_block|

      condition = statement_block[0].split("case")[1].strip

      statement_block[0] = "switch(#{condition}) {\n\n"

      when_statements = statement_block.reject {|element| !replace_strings(element).include?("when")}

      when_statements_index = []

      when_statements.each do |statement|

        when_statements_index << statement_block.each_index.select{|index| statement_block[index] == statement}

      end

      when_statements_index = when_statements_index.flatten

      if replace_strings(statement_block.join).include?("else\n")

        else_statement = statement_block.reject {|element| !replace_strings(element).strip.eql?("else")}

        else_block = statement_block[statement_block.index(else_statement[0])+1...-1]

        when_statements_index = when_statements_index + statement_block.each_index.select {|index| statement_block[index] == else_statement[0] }.to_a

        when_statements_index = when_statements_index.flatten

        statement_block[statement_block.index(else_statement[0])..-1] = ["default: %$%$ {\n\n",else_block.collect{|element| "  " + element.strip + "\n\n"},"%$%$\n}\n\n}\n\n"].flatten

        when_statement_blocks = []

        when_statements.each_with_index do |statement,ind|

          when_block = statement_block[when_statements_index[ind]...when_statements_index[ind+1]]

          when_statement_blocks << when_block

        end

        replacement_blocks = when_statement_blocks.collect {|element| compile_when_statement(element)}

      else

        statement_block[-1] = "}\n\n" if statement_block[-1].strip.eql?("end")

        when_statement_blocks = []

        when_statements_index << -1

        when_statements.each_with_index do |statement,ind|

          when_block = statement_block[when_statements_index[ind]...when_statements_index[ind+1]]

          when_statement_blocks << when_block

        end

        replacement_blocks = when_statement_blocks.collect {|element| compile_when_statement(element)}

      end

      statement_block = statement_block.join

      when_statement_blocks.each_with_index do |blck,index|

        statement_block = statement_block.sub(blck.join,replacement_blocks[index])

      end

      replacement_strings << statement_block

    end

    joined_file_contents = modified_file_contents.join

    legacy.each_with_index do |statement,index|

      joined_file_contents = joined_file_contents.sub(statement.join,replacement_strings[index])

    end

    file_id = open(temporary_nila_file, 'w')

    file_id.write(joined_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_nila_file)

    return line_by_line_contents

  end