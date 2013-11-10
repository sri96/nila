Feature: Adding automatic return statements to the last evaluated statement
in a function. It is a rubyesque feature imported into Nila.  
  Scenario: Input function with no return statement
    Given the input file "no_return.nila"
    When the ~compiler is run
    The output file must be "no_return.js"
    The output file must equal "correct_return.js"

   Scenario: Input function with a return statement
    Given the input file "single_return.nila"
    When the ~compiler is run
    The output file must be "single_return.js"
    The output file must equal "correct_single_return.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file