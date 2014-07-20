Feature: This feature bring Ruby's Different Array features to Nila
  Scenario: Input file with multiple Ruby style arrays
    Given the input file "arrays.nila"
    When the ~compiler is run
    The output file must be "arrays.js"
    The output file must equal "correct_arrays.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file