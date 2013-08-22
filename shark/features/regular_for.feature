Feature: Compiling for loops in a nila program
  Scenario: Input with several kinds of for loops
    Given the input file "regular_for.nila"
    When the ~compiler is run
    The output file must be "regular_for.js"
    The output file must equal "correct_for.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file