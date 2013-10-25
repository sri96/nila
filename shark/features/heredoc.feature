Feature: This feature brings heredocs to Nila
  Scenario: Input file with heredocs. 
    Given the input file "heredoc.nila"
    When the ~compiler is run
    The output file must be "heredoc.js"
    The output file must equal "correct_heredoc.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --compile $file