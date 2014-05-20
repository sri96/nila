#Nilac is the official Nila compiler. It compiles Nila into pure Javascript. Nilac is currently
#written in Ruby but will be self hosted in the upcoming years.

#Nila and Nilac are being crafted by Adhithya Rajasekaran and Sri Madhavi Rajasekaran

#All the code in this project is licensed under the MIT License

$LOAD_PATH << File.dirname(__FILE__)

module Nilac
  
  require 'nilac/version'
  require 'fileutils'
  require 'nilac/read_file_line_by_line'
  require 'nilac/add_line_numbers'
  require 'nilac/find_file_name'
  require 'nilac/find_file_path'
  require 'nilac/extract_parsable_file'
  require 'nilac/compile_require_statements'
  require 'nilac/replace_multiline_comments'
  require 'nilac/split_semicolon_seperated_expressions'
  require 'nilac/compile_heredocs'
  require 'nilac/compile_interpolated_strings'
  require 'nilac/replace_singleline_comments'
  require 'nilac/replace_named_functions'
  require 'nilac/compile_parallel_assignment'
  require 'nilac/compile_default_values'
  require 'nilac/get_variables'
  require 'nilac/remove_question_marks'
  require 'nilac/compile_arrays'
  require 'nilac/compile_hashes'
  require 'nilac/compile_strings'
  require 'nilac/compile_integers'
  require 'nilac/compile_named_functions'
  require 'nilac/compile_custom_function_map'
  require 'nilac/compile_ruby_methods'
  require 'nilac/compile_special_keywords'
  require 'nilac/compile_whitespace_delimited_functions'
  require 'nilac/compile_conditional_structures'
  require 'nilac/compile_case_statement'
  require 'nilac/compile_loops'
  require 'nilac/compile_lambdas'
  require 'nilac/compile_blocks'
  require 'nilac/add_semicolons'
  require 'nilac/compile_comments'
  require 'nilac/pretty_print_javascript'
  require 'nilac/compile_operators'
  require 'nilac/output_javascript'
  require 'nilac/create_mac_executable'
  require 'nilac/parse_arguments'
  require 'nilac/friendly_errors'
  require 'nilac/compile_monkey_patching'
  require 'nilac/compile_ranges'
  require 'nilac/compile_chained_comparison'
  require 'nilac/compile_new_keyword'

  class NilaCompiler

    include FriendlyErrors

    def initialize(args)

      @input_arguments = args

    end

    def compile(input_file_path, options = [], *output_file_name)

      message,proceed = file_exist?(input_file_path)

      if proceed

        file_contents = read_file_line_by_line(input_file_path)

        line_numbered_file_contents = add_line_numbers(file_contents)

        file_contents = file_contents.collect {|element| element.gsub("\r\n","\n")}

        file_contents = file_contents.collect {|element| element.gsub(".end",".enttttttttttt")}

        file_contents = extract_parsable_file(file_contents)

        file_contents = compile_require_statements(file_contents)

        proceed = check_comments(line_numbered_file_contents)

        if proceed

          file_contents, multiline_comments, temp_file, output_js_file = replace_multiline_comments(file_contents, input_file_path, *output_file_name)

          file_contents, singleline_comments = replace_singleline_comments(file_contents)

          file_contents = split_semicolon_seperated_expressions(file_contents)

          file_contents = compile_ranges(file_contents)

          file_contents = compile_heredocs(file_contents, temp_file)

          file_contents,lambda_names = compile_lambdas(file_contents,temp_file)

          file_contents,loop_vars = compile_loops(file_contents,temp_file)

          file_contents, interpolation_vars  = compile_interpolated_strings(file_contents)

          file_contents = compile_hashes(file_contents,temp_file)

          file_contents = compile_case_statement(file_contents,temp_file)

          file_contents = compile_conditional_structures(file_contents, temp_file)

          file_contents = compile_blocks(file_contents,temp_file)

          file_contents = compile_integers(file_contents)

          file_contents = compile_default_values(file_contents, temp_file)

          file_contents, named_functions, nested_functions = replace_named_functions(file_contents, temp_file)

          comments = [singleline_comments, multiline_comments]

          file_contents = compile_parallel_assignment(file_contents, temp_file)

          file_contents,named_functions = compile_arrays(file_contents, named_functions, temp_file)

          file_contents = compile_strings(file_contents)

          list_of_variables, file_contents = get_variables(file_contents, temp_file,loop_vars)

          file_contents, function_names = compile_named_functions(file_contents, named_functions, nested_functions, temp_file)

          file_contents = compile_monkey_patching(file_contents,temp_file)

          func_names = function_names.dup

          file_contents, ruby_functions = compile_custom_function_map(file_contents)

          file_contents = compile_ruby_methods(file_contents)

          file_contents = compile_special_keywords(file_contents)

          function_names << ruby_functions

          function_names << lambda_names

          list_of_variables += loop_vars

          list_of_variables += interpolation_vars

          file_contents = compile_whitespace_delimited_functions(file_contents, function_names, temp_file)

          file_contents = remove_question_marks(file_contents, list_of_variables, temp_file)

          file_contents = add_semicolons(file_contents)

          file_contents = compile_new_keyword(file_contents)

          file_contents = compile_comments(file_contents, comments, temp_file)

          file_contents = pretty_print_javascript(file_contents, temp_file,list_of_variables+func_names)

          file_contents = compile_operators(file_contents)

          file_contents = file_contents.collect {|element| element.gsub(".enttttttttttt",".end")}

          output_javascript(file_contents, output_js_file, temp_file)

          puts "Compilation is successful!"

        end

      else

        puts message

      end


    end

    def start_compile

      opts = parse_arguments(@input_arguments)
      nilac_version = Nilac::VERSION

      if opts.values.compact.empty?

        opts[:help] = "-h"

      end

      if opts[:build] != nil

        file_path = Dir.pwd + "/src/nilac.rb"
        create_mac_executable(file_path)
        FileUtils.mv("#{file_path[0...-3]}", "#{Dir.pwd}/bin/nilac")
        puts "Build Successful!"

      elsif opts[:compile] != nil

        client_optimized = false
        server_optimized = false

        if opts[:compile].include?("--browser") or opts[:compile].include?("--client")

          client_optimized = true
          opts[:compile] = opts[:compile].delete("--browser")
          opts[:compile] = opts[:compile].delete("--client")

        elsif opts[:compile].include?("--server") or opts[:compile].include?("--node")

          server_optimized = true
          opts[:compile] = opts[:compile].delete("--server")
          opts[:compile] = opts[:compile].delete("--node")

        end

        if opts[:compile].length == 1

          input = opts[:compile][0]

          if input.include? ".nila"
            current_directory = Dir.pwd
            input_file = input
            file_path = current_directory + "/" + input_file
            compile(file_path,[client_optimized,server_optimized])
          elsif File.directory?(input)
            folder_path = input
            files = Dir.glob(File.join(folder_path, "*"))
            files = files.reject { |path| !path.include? ".nila" }
            files.each do |file|
              file_path = Dir.pwd + "/" + file
              compile(file_path,[client_optimized,server_optimized])
            end
          end

        elsif opts[:compile].length == 2

          input = opts[:compile][0]
          output = opts[:compile][1]

          if input.include? ".nila" and output.include? ".js"

            input_file = input
            output_file = output
            input_file_path = input_file
            output_file_path = output_file
            compile(input_file_path, [client_optimized,server_optimized],output_file_path)

          elsif File.directory?(input)

            input_folder_path = input
            output_folder_path = output

            if !File.directory?(output_folder_path)
              FileUtils.mkdir_p(output_folder_path)
            end

            files = Dir.glob(File.join(input_folder_path, "*"))
            files = files.reject { |path| !path.include? ".nila" }

            files.each do |file|
              input_file_path = file
              output_file_path = output_folder_path + "/" + find_file_name(file, ".nila") + ".js"
              compile(input_file_path,[client_optimized,server_optimized],output_file_path)
            end

          end

        end

      elsif opts[:help] != nil

        puts "Nilac is the official compiler for the Nila language.This is a basic help\nmessage with pointers to more information.\n\n"
        puts "  Basic Usage:\n\n"
        puts "    nilac -h/--help\n"
        puts "    nilac -v/--version\n"
        puts "    nilac -u/--update => Update Checker\n"
        puts "    nilac [command] [sub_commands] [file_options]\n\n"
        puts "  Available Commands:\n\n"
        puts "    nilac -c [nila_file] => Compile Nila File\n\n"
        puts "    nilac -c [nila_file] [output_js_file] => Compile nila_file and saves it as\n    output_js_file\n\n"
        puts "    nilac -c [nila_file_folder] => Compiles each .nila file in the nila_folder\n\n"
        puts "    nilac -c [nila_file_folder] [output_js_file_folder] => Compiles each .nila\n    file in the nila_folder and saves it in the output_js_file_folder\n\n"
        puts "    nilac -r [nila_file] => Compile and Run nila_file\n\n"
        puts "  Further Information:\n\n"
        puts "    Visit http://adhithyan15.github.io/nila to know more about the project.\n\n"

      elsif opts[:run] != nil

        current_directory = Dir.pwd
        file = opts[:run][0]
        commandline_args = opts[:run][1..-1]
        file_path = current_directory + "/" + file
        compile(file_path)
        js_file_name = find_file_path(file_path, ".nila") + find_file_name(file_path, ".nila") + ".js"
        node_output = `node #{js_file_name} #{commandline_args.join(" ")}`
        puts node_output

      elsif opts[:update] != nil

        puts "Checking for updates......"
        outdated_gems = `gem outdated`
        outdated_gems = outdated_gems.split("\n")
        outdated = false
        old_version = ""
        new_version = ""

        outdated_gems.each do |gem_name|

          if gem_name.include?("nilac")
            outdated = true
            old_version = gem_name.split("(")[1].split(")")[0].split("<")[0].lstrip
            new_version = gem_name.split("(")[1].split(")")[0].split("<")[1].lstrip.rstrip
            break
          end

        end

        if outdated
          exec = `gem update nilac`
          puts "Your version of Nilac (#{old_version}) was outdated! We have automatically updated you to the latest version (#{new_version})."
        else
          puts "Your version of Nilac is up to date!"
        end

      elsif opts[:version] != nil

        puts nilac_version

      end

    end

  end

end

if ARGV.include?("--test")

  ARGV.delete("--test")
  compiler = Nilac::NilaCompiler.new(ARGV)
  compiler.start_compile()

end