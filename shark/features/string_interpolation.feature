Feature: This feature bring Ruby style string interpolation to Nila   
  Scenario: Input file with string interpolation
    Given the input file "string_interpolation.nila"
    When the ~compiler is run
    The output file must be "string_interpolation.js"
    The output file must equal "correct_string_interpolation.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file