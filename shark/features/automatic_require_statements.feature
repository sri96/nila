Feature: Automatically add variable declaration for required modules. Very useful for Node.js developers.
  Scenario: Input file with required modules
    Given the input file "required_module.nila"
    When the ~compiler is run
    The output file must be "required_module.js"
    The output file must equal "correct_required_module.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file