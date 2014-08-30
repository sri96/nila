require_relative 'replace_strings'
require_relative 'extract_paranthesis_contents'

def fix_javascript_traps(input_file_contents)

  # One of the design goals of Nila is to fix to Javascript traps

  # parseInt is a potential trap if you forget the radix parameter. So
  # Nila automatically includes the radix parameter of 10 if you forget to include a parameter
  # so that you don't get weird conversions like the one mentioned in
  # http://stackoverflow.com/questions/850341/how-do-i-work-around-javascripts-parseint-octal-behavior

  def fix_parseint_default(input_file_contents)

    possible_parseints = input_file_contents.reject {|element| !replace_strings(element).include?("parseInt")}

    no_radix = []

    no_radix_lines = []

    possible_parseints.each do |str|

      index = input_file_contents.index(str)

      no_radix << []

      no_radix_lines << []

      paran_extracts = extract_paranthesis_contents(str)

      paran_extracts = paran_extracts.reject {|element| element.strip.eql?("")}

      paran_extracts.each do |extract|

        if input_file_contents[index].include?("parseInt#{extract}")

          extracted_parseint = "parseInt#{extract}"

          extract_split = replace_strings(extract).split(",")

          if extract_split.length == 1

            no_radix[-1] << extracted_parseint

            no_radix_lines[-1] << input_file_contents[index]

          end

        end

      end

    end

    no_radix_lines = no_radix_lines.collect{|element| element.uniq}

    no_radix_lines = no_radix_lines.reject {|element| element.empty?}

    no_radix = no_radix.reject {|element| element.empty?}

    no_radix_lines.each_with_index do |element,index|

      extracted_parseints = no_radix[index]

      modified_element = element[0].clone

      extracted_parseints.each do |parseint|

        replacement_string = parseint[0...-1] + ",10" + parseint[-1]

        modified_element = modified_element.sub(parseint,replacement_string)

      end

      input_file_contents[input_file_contents.index(element[0])] = modified_element

    end

    return input_file_contents

  end

  def compile_parseint_variants(input_file_contents)

    possible_parseint_variants = input_file_contents.reject {|element| !replace_strings(element).index(/parse(Hex|Oct|Binary)/) }

    puts possible_parseint_variants.to_s

  end

  input_file_contents = fix_parseint_default(input_file_contents)

  #compile_parseint_variants(input_file_contents)

  return input_file_contents


end