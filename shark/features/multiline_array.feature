Feature: This feature brings multiline arrays to Nila
  Scenario: Input file with multiline array and regular arrays. 
    Given the input file "multiline_array.nila"
    When the ~compiler is run
    The output file must be "multiline_array.js"
    The output file must equal "correct_multiline_array.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file