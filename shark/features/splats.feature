Feature: This feature brings powerful Splat arguments for Methods/Functions    
  Scenario: Input file with multiple splats parameters for methods/functions
    Given the input file "splats.nila"
    When the ~compiler is run
    The output file must be "splats.js"
    The output file must equal "correct_splats.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file