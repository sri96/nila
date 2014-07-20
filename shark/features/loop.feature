Feature: This feature brings loop keyword to Nila
  Scenario: Input file with loop keyword. 
    Given the input file "loop.nila"
    When the ~compiler is run
    The output file must be "loop.js"
    The output file must equal "correct_loop.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file