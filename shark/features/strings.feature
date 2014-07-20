Feature: This feature bring Ruby's string features to Nila   
  Scenario: Input file with different operators
    Given the input file "string_operators.nila"
    When the ~compiler is run
    The output file must be "string_operators.js"
    The output file must equal "correct_string_operators.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file