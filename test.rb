# This script will use RVM and Shark test runner to test Nilac on multiple different
# Ruby versions and tell you which ones failed and which ones ran ok.

rvm_output = `rvm use ruby-2.0.0-p247`

shark_output = `shark -t`

if shark_output.include?("from lib/nilac.rb:")
    
    puts "Test failed for ruby-2.0.0-p247"

else
    
    puts shark_output
    
    puts "\nAll tests are passing on ruby-2.0.0-p247\n"
    
end

rvm_output = `rvm use jruby-1.7.4`

shark_output = `shark -t`

if shark_output.include?("from lib/nilac.rb:")
    
    puts "Test failed for jruby-1.7.4"

else
    
    puts shark_output
    
    puts "\nAll tests are passing on jruby-1.7.4\n"
    
end
