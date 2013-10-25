Feature: This feature brings Ruby style Hashes to Nila
  Scenario: Input file with hashes. 
    Given the input file "hashes.nila"
    When the ~compiler is run
    The output file must be "hashes.js"
    The output file must equal "correct_hashes.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file