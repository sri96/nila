def compile_ruby_math(input_file_contents)

  # Ruby and Javascript both has powerful features. This library will be used to compile
  # code written using the Ruby math library into Javascript Math library code

  constant_value_map = {

      "Math::E" => "Math.E",

      "Math::sqrt" => "Math.sqrt",

      "Float::EPSILON" => "Math.EPSILON",

  }

  constant_value_map.each do |key,value|

    input_file_contents = input_file_contents.collect {|element| element.gsub(key,value)}

  end

  return input_file_contents

end