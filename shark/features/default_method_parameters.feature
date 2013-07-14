Feature: Javascript,by default,doesn't allow for the usage of default parameters for functions. So this
feature addresses that issue.  
  Scenario: Input function with default parameters
    Given the input file "default_parameters.nila"
    When the ~compiler is run
    The output file must be "default_parameters.js"
    The output file must equal "correct_default_parameters.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file