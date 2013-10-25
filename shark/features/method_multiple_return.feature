Feature: Javascript, by default, doesn't allow for the return of multiple values. So this is Nila's attempt to fix this problem.   
  Scenario: Input function with multiple return statement
    Given the input file "multiple_return.nila"
    When the ~compiler is run
    The output file must be "multiple_return.js"
    The output file must equal "correct_multiple_return.js"

   Scenario: Input function with a single return statement
    Given the input file "single_return.nila"
    When the ~compiler is run
    The output file must be "single_return.js"
    The output file must equal "correct_single_return.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file