Feature: Compiling a single line nila program
  Scenario: Input with a single line nila program
    Given the input file "simple.nila"
    When the ~compiler is run
    The output file must be "simple.js"
    The output file must equal "correct.js"

Configurations:

~compiler => bin/nilac.rb
:v $cliusage => ruby :v --compile $file