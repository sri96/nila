require_relative 'compile_existential_operator'

def compile_operators(input_file_contents)

  def compile_power_operator(input_string)

    matches = input_string.scan(/(\w{1,}\*\*\w{1,})/).to_a.flatten

    unless matches.empty?

      matches.each do |match|

        left, right = match.split("**")

        input_string = input_string.sub(match, "Math.pow(#{left},#{right})")

      end

    end

    return input_string

  end

  def compile_match_operator(input_string)

    rejection_exp = /( aannddy | orriioo |nnoottyy )/

    if input_string.include?("=~")

      input_string = input_string.gsub(" && ", " aannddy ").gsub(" || ", " orriioo ").gsub("!", "nnoottyy")

      left, right = input_string.split("=~")

      if left.index(rejection_exp) != nil

        left = left[left.index(rejection_exp)..-1]

      elsif left.index(/\(/)

        left = left[left.index(/\(/)+1..-1]

      end

      if right.index(rejection_exp) != nil

        right = right[0...right.index(rejection_exp)]

      elsif right.index(/\)/)

        right = right[0...right.index(/\)/)]

      end

      original_string = "#{left}=~#{right}"

      replacement_string = "#{left.rstrip} = #{left.rstrip}.match(#{right.lstrip.rstrip})"

      input_string = input_string.sub(original_string, replacement_string)

      input_string = input_string.gsub(" aannddy ", " && ").gsub(" orriioo ", " || ").gsub("nnoottyy", "!")

    end

    return input_string

  end

  input_file_contents = input_file_contents.collect { |element| element.sub("==", "===") }

  input_file_contents = input_file_contents.collect { |element| element.sub("!=", "!==") }

  input_file_contents = input_file_contents.collect { |element| element.sub("equequ", "==") }

  input_file_contents = input_file_contents.collect { |element| element.sub("elsuf", "else if") }

  input_file_contents = compile_existential_operators(input_file_contents)

  input_file_contents = compile_undefined_operator(input_file_contents)

  input_file_contents = input_file_contents.collect { |element| compile_power_operator(element) }

  input_file_contents = input_file_contents.collect { |element| compile_match_operator(element) }

  input_file_contents = input_file_contents.collect { |element| element.gsub("_!;", ";") }

  return input_file_contents

end