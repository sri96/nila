  def compile_classes(input_file_contents)

    # Nila will have support for classes. But the current implementation is not ready for prime time
    # yet. So it won't be documented.

    def extract_classes(file_contents)

      # This method will extract code blocks between class .. end blocks and try to convert to
      # Javascript equivalent code

      possible_classes = file_contents.reject {|element| !element.index(/class\s*\w{1,}\s*<?\s?\w{1,}?/)}



    end

    extract_classes(input_file_contents)

  end
