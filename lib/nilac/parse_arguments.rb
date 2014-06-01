def parse_arguments(input_argv)
    
  argument_map = {
      
    %w{c compile} => "compile",
      
    %w{r run} => "run",
      
    %w{h help} => "help",
      
    %w{v version} => "version",

    %w{u update} => "update",
      
  }

  output_hash = {}

  argument_map.each do |key,val|
  
    if input_argv.include?("-#{key[0]}") or input_argv.include?("--#{key[1]}")
    
       output_hash[val.to_sym] = input_argv.reject {|element| element.include?("-#{key[0]}")} if input_argv.include?("-#{key[0]}")
            
       output_hash[val.to_sym] = input_argv.reject {|element| element.include?("--#{key[1]}")} if input_argv.include?("--#{key[1]}")
        
    else
        
       output_hash[val.to_sym] = nil
        
    end

  end

  if output_hash.values.compact.empty? and !input_argv.empty?

    if input_argv[0].include?(".nila")

      output_hash[:run] = [input_argv[0]]

    elsif File.directory?(input_argv[0])

      puts "\nSorry! Nilac cannot compile and run folders full of source files at this time.\n\n"

      puts "Check out the documentation at https://adhithyan15.github.io/nila#cli-options\nif you have any questions\n\n"

      exit

    end

  end

  return output_hash
    
end