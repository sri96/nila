Feature: This feature bring Ruby's methods to Nila   
  Scenario: Input file with method declarations
    Given the input file "methods.nila"
    When the ~compiler is run
    The output file must be "methods.js"
    The output file must equal "correct_methods.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file