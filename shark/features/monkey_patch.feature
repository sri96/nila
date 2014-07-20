Feature: This feature brings monkey patching/duck punching prototypes to Nila
  Scenario: Input file with monkey patched prototypes 
    Given the input file "monkey_patch.nila"
    When the ~compiler is run
    The output file must be "monkey_patch.js"
    The output file must equal "correct_monkey_patch.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file