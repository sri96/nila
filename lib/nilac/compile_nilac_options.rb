require_relative 'read_file_line_by_line'

def compose_nilac_options(input_options = {})

  available_options = %w{bare strict-mode client server print}

  output_options = {

      :bare => false,

      :strict_mode => false,

      :client => false,

      :server => true,

      :print => false

  }

  options = input_options.clone.reject {|key,value| value.nil?}

  options.each do |key,value|

    current_options = options[key]

    if current_options.include?("--bare") or current_options.include?("-b")

      output_options[:bare] = true

      input_options[key].delete("--bare")

      input_options[key].delete("-b")

    end

    if current_options.include?("--strict-mode")

      output_options[:strict_mode] = true

      input_options[key].delete("--strict-mode")

    end

    if current_options.include?("--client") or current_options.include?("--browser")

      output_options[:client] = true

      input_options[key].delete("--client")

      input_options[key].delete("--browser")

    end

    if current_options.include?("--server") or current_options.include?("--node")

      output_options[:node] = true

      input_options[key].delete("--server")

      input_options[key].delete("--node")

    end

    if current_options.include?("--print") or current_options.include?("-p")

      output_options[:print] = true

      input_options[key].delete("--print")

      input_options[key].delete("-p")

    end

  end

  return output_options

end
