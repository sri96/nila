Feature: Fixing irregular newlines produced in the Javascript output.
Currently, The output Javascript is riddled with unnecessary newlines
which will make it fail in a JSLint test. 
  Scenario: Input with erratic newlines
    Given the input file "erratic.nila"
    When the ~compiler is run
    The output file must be "erratic.js"
    The output file must equal "correct_spacing.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file