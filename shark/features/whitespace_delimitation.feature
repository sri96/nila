Feature: This feature brings whitespace delimitation features to Nila
  Scenario: Input file with whitespace delimitation features. 
    Given the input file "whitespace_delimiter.nila"
    When the ~compiler is run
    The output file must be "whitespace_delimiter.js"
    The output file must equal "correct_whitespace_delimiter.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file