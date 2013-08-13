Feature: This feature brings single line if-then-else statement to Nila
  Scenario: Input file with single line if-then-else statement. 
    Given the input file "if_then_else.nila"
    When the ~compiler is run
    The output file must be "if_then_else.js"
    The output file must equal "correct_if_then_else.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file