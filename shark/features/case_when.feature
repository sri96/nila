Feature: This feature bring Ruby's case when structure to Nila   
  Scenario: Input file with multiple case when structures
    Given the input file "case.nila"
    When the ~compiler is run
    The output file must be "case.js"
    The output file must equal "correct_case.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file