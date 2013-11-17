Feature: This feature introduces .undefined?, .nil? and .exist? operators to help Javascript development.   
  Scenario: Input file with different operators
    Given the input file "javascript_methods.nila"
    When the ~compiler is run
    The output file must be "javascript_methods.js"
    The output file must equal "correct_javascript_methods.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file