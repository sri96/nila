Feature: This feature brings various Ruby variable declaration features to Nila
  Scenario: Input file with different variable declarations 
    Given the input file "variables.nila"
    When the ~compiler is run
    The output file must be "variables.js"
    The output file must equal "correct_variables.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file