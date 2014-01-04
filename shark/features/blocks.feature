Feature: This feature bring Ruby's case when structure to Nila   
  Scenario: Input file with multiple case when structures
    Given the input file "blocks.nila"
    When the ~compiler is run
    The output file must be "blocks.js"
    The output file must equal "correct_blocks.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file