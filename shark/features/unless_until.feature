Feature: This feature bring Ruby's unless and until statements to Nila.   
  Scenario: Input function with unless and until statements
    Given the input file "unless_until.nila"
    When the ~compiler is run
    The output file must be "unless_until.js"
    The output file must equal "correct_unless_until.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file