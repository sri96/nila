def parse_arguments(input_argv)
    
  argument_map = {
      
    %w{c compile} => "compile",
      
    %w{r run} => "run",
      
    %w{h help} => "help",
      
    %w{v version} => "version",
      
    %w{b build} => "build",
      
    %w{u update} => "update",
      
    %w{re release} => "release",
      
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

  return output_hash
    
end