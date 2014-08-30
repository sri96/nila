Feature: Compiling a simple nila program without the safety wrapper
  Scenario: Input with a simple nila program with a --bare option
    Given the input file "bare.nila"
    When the ~compiler is run
    The output file must be "bare.js"
    The output file must equal "correct_bare.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile --bare $file