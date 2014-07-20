Feature: This feature brings Ruby's number features to Nila
  Scenario: Input file with Ruby's number features. 
    Given the input file "numbers.nila"
    When the ~compiler is run
    The output file must be "numbers.js"
    The output file must equal "correct_numbers.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file