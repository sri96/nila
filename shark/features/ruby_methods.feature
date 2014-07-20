Feature: This feature brings Ruby's native String and Array methods to Nila.   
  Scenario: Input function with several native Ruby methods
    Given the input file "ruby_methods.nila"
    When the ~compiler is run
    The output file must be "ruby_methods.js"
    The output file must equal "correct_ruby_methods.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file