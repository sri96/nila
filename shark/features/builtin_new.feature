Feature: This feature bring Ruby's builtin class's new method to Javascript   
  Scenario: Input file with multiple built class intialization by calling new method
    Given the input file "builtin_new.nila"
    When the ~compiler is run
    The output file must be "builtin_new.js"
    The output file must equal "correct_builtin_new.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file