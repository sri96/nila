Feature: This feature bring Ruby's while statement to Nila.   
  Scenario: Input function with while statements
    Given the input file "regular_while.nila"
    When the ~compiler is run
    The output file must be "regular_while.js"
    The output file must equal "correct_regular_while.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file