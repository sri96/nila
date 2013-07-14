Feature: This feature bring Ruby style if statements to Nila.   
  Scenario: Input function with regular if statements
    Given the input file "regular_if.nila"
    When the ~compiler is run
    The output file must be "regular_if.js"
    The output file must equal "correct_regular_if.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file