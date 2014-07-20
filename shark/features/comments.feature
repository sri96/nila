Feature: This feature bring Ruby's style comments to Nila   
  Scenario: Input file with multiple versions of comments
    Given the input file "comments.nila"
    When the ~compiler is run
    The output file must be "comments.js"
    The output file must equal "correct_comments.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file