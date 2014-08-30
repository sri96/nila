Feature: This feature brings HTML entities to Nila
  Scenario: Input file with native HTML entities. 
    Given the input file "html_symbols.nila"
    When the ~compiler is run
    The output file must be "html_symbols.js"
    The output file must equal "correct_html_symbols.js"

Configurations:

~compiler => lib/nilac.rb
:v $cliusage => ruby :v --test --compile $file