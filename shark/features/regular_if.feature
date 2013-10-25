Feature: This feature bring Ruby's if statement to Nila.   
  Scenario: Input function with if statements
    Given the input file "regular_if.nila"
    When the ~compiler is run
    The output file must be "regular_if.js"
    The output file must equal "correct_regular_if.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file