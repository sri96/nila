Feature: This feature brings Ruby's .times method to Nila
  Scenario: Input file with Ruby's .times method 
    Given the input file "times.nila"
    When the ~compiler is run
    The output file must be "times.js"
    The output file must equal "correct_times.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file