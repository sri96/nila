Feature: This feature bring Ruby style operators to Nila   
  Scenario: Input file with different operators
    Given the input file "operators.nila"
    When the ~compiler is run
    The output file must be "operators.js"
    The output file must equal "correct_operators.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file