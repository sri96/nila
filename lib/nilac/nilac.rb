#Nilac is the official Nila compiler. It compiles Nila into pure Javascript. Nilac is currently
#written in Ruby but will be self hosted in the upcoming years.

#Nila and Nilac are being crafted by Adhithya Rajasekaran and Sri Madhavi Rajasekaran

require 'fileutils'

require_relative 'read_file_line_by_line'

require_relative 'find_file_name'

require_relative 'find_file_path'

require_relative 'extract_parsable_file'

require_relative 'replace_multiline_comments'

require_relative 'split_semicolon_seperated_expressions'

require_relative 'compile_heredocs'

require_relative 'compile_interpolated_strings'

require_relative 'replace_singleline_comments'

require_relative 'replace_named_functions'

require_relative 'compile_parallel_assignment'

require_relative 'compile_default_values'

require_relative 'get_variables'

require_relative 'remove_question_marks'

require_relative 'compile_arrays'

require_relative 'compile_hashes'

require_relative 'compile_strings'

require_relative 'compile_integers'

require_relative 'compile_classes'

require_relative 'compile_named_functions'

require_relative 'compile_custom_function_map'

require_relative 'compile_ruby_methods'

require_relative 'compile_special_keywords'

require_relative 'compile_whitespace_delimited_functions'

require_relative 'compile_conditional_structures'

require_relative 'compile_case_statement'

require_relative 'compile_loops'

require_relative 'compile_blocks'

require_relative 'add_semicolons'

require_relative 'compile_comments'

require_relative 'pretty_print_javascript'

require_relative 'compile_operators'

require_relative 'output_javascript'

require_relative 'create_mac_executable'

require_relative 'parse_arguments'

class NilaCompiler

  def initialize(args)

    @input_arguments = args

  end

  def compile(input_file_path, *output_file_name)

    if File.exist?(input_file_path)

      file_contents = read_file_line_by_line(input_file_path)

      file_contents = extract_parsable_file(file_contents)

      file_contents, multiline_comments, temp_file, output_js_file = replace_multiline_comments(file_contents, input_file_path, *output_file_name)

      file_contents, singleline_comments = replace_singleline_comments(file_contents)

      file_contents = split_semicolon_seperated_expressions(file_contents)

      file_contents = compile_heredocs(file_contents, temp_file)

      file_contents,loop_vars = compile_loops(file_contents,temp_file)

      file_contents = compile_interpolated_strings(file_contents)

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

      func_names = function_names.dup

      file_contents, ruby_functions = compile_custom_function_map(file_contents)

      file_contents = compile_ruby_methods(file_contents)

      file_contents = compile_special_keywords(file_contents)

      function_names << ruby_functions

      list_of_variables += loop_vars

      file_contents = compile_whitespace_delimited_functions(file_contents, function_names, temp_file)

      file_contents = remove_question_marks(file_contents, list_of_variables, temp_file)

      file_contents = add_semicolons(file_contents)

      file_contents = compile_comments(file_contents, comments, temp_file)

      file_contents = pretty_print_javascript(file_contents, temp_file,list_of_variables+func_names)

      file_contents = compile_operators(file_contents)

      output_javascript(file_contents, output_js_file, temp_file)

      puts "Compilation is successful!"

    else

      puts "File doesn't exist!"

    end

  end

  def start_compile

    opts = parse_arguments(@input_arguments)

    nilac_version = "0.0.4.3.9.3"

    if opts.values.compact.empty?

      opts[:help] = "-h"

    end

    if opts[:build] != nil

      file_path = Dir.pwd + "/src/nilac.rb"
      create_mac_executable(file_path)
      FileUtils.mv("#{file_path[0...-3]}", "#{Dir.pwd}/bin/nilac")
      puts "Build Successful!"

    elsif opts[:compile] != nil

      if opts[:compile].length == 1

        input = opts[:compile][0]

        if input.include? ".nila"
          current_directory = Dir.pwd
          input_file = input
          file_path = current_directory + "/" + input_file
          compile(file_path)
        elsif input.include? "/"
          folder_path = input
          files = Dir.glob(File.join(folder_path, "*"))
          files = files.reject { |path| !path.include? ".nila" }
          files.each do |file|
            file_path = Dir.pwd + "/" + file
            compile(file_path)
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
          compile(input_file_path, output_file_path)

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
            compile(input_file_path, output_file_path)
          end

        end

      end

    elsif opts[:help] != nil

      puts "Nilac is the official compiler for the Nila language.This is a basic help\nmessage with pointers to more information.\n\n"
      puts "  Basic Usage:\n\n"
      puts "    nilac -h/--help\n"
      puts "    nilac -v/--version\n"
      puts "    nilac -u/--update => Update Checker\n"
      puts "    nilac [command] [file_options]\n\n"
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

    elsif opts[:release] != nil

      file_path = Dir.pwd + "/src/nilac.rb"
      create_mac_executable(file_path)
      FileUtils.mv("#{file_path[0...-3]}", "#{Dir.pwd}/bin/nilac")
      puts "Your build was successful!\n"
      commit_message = opts[:release][0]
      `git commit -am "#{commit_message}"`
      puts `rake release`

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
