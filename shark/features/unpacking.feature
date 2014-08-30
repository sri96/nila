Feature: This feature bring unpacking statement support from Coffeescript.   
  Scenario: Input function with unpacking statements
    Given the input file "unpacking.nila"
    When the ~compiler is run
    The output file must be "unpacking.js"
    The output file must equal "correct_unpacking.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file