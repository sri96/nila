  def find_all_matching_indices(input_string, pattern)

    locations = []

    index = input_string.index(pattern)

    while index != nil

      locations << index

      index = input_string.index(pattern, index+1)


    end

    return locations

  end