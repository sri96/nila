    def replace_strings(input_string)

      string_counter = 0

      if input_string.count("\"") % 2 == 0

        while input_string.include?("\"")

        string_extract = input_string[input_string.index("\"")..input_string.index("\"",input_string.index("\"")+1)]

        input_string = input_string.sub(string_extract,"--repstring#{string_counter}")

        string_counter += 1

        end

      end

      if input_string.count("'") % 2 == 0

        while input_string.include?("'")

          string_extract = input_string[input_string.index("'")..input_string.index("'",input_string.index("'")+1)]

          input_string = input_string.sub(string_extract,"--repstring#{string_counter}")

          string_counter += 1

        end

      end

      return input_string

    end
