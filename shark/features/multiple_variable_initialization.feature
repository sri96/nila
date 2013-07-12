Feature: Javascript doesn't allow multiple variable initializations from a method call. So this feature attempts to fix this problem. This feature is complementary to the multiple return feature.

  Scenario: Multiple variables initialized from a method call.
    Given the input file "multiple_initialization.nila"
    When the ~compiler is run
    The output file must be "multiple_initialization.js"
    The output file must equal "correct_initialization.js"

Configurations:

~compiler => src/nilac.rb
:v $cliusage => ruby :v --compile $file