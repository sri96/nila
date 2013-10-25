Feature: This feature bring Ruby's indexing capabililty to Javascript.  
  Scenario: Input file with Ruby style Array and String indexing
    Given the input file "array_string_indexing.nila"
    When the ~compiler is run
    The output file must be "array_string_indexing.js"
    The output file must equal "correct_indexing.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file