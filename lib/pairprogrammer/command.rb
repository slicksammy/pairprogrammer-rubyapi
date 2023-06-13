require_relative 'configuration'
require 'fileutils'
require 'open3'

module PairProgrammer
    class Command
        def self.display_command(command, arguments)
            case command
            when "yarn"
                "running `yarn #{arguments["command"]}`"
            when "mv"
                puts "moving #{arguments["source"]} to #{arguments["destination"]}"
            when "python"
                "running `python #{arguments["command"]}`"
            when "ls"
                "listing files and directories for #{arguments["directory_path"]}"
            when "bundle"
                puts "running `bundle #{arguments["command"]}`"
            when "rails"
                "running `rails #{arguments["command"]}`"
            when "comment"
                nil
            when "write_file"
                puts "updating #{arguments["file_path"]}"
            when "create_directory"
                puts "creating directory #{arguments["directory_path"]}"
            when "delete_file"
                puts "deleting #{arguments["file_path"]}"
            when "view_changes"
                # TODO
            when "delete_lines"
                puts "deleting lines #{line_numbers} from #{arguments["file_path"]}"
            when "rspec"
                puts "running `rspec #{arguments["file_path"]}`"
            when "ask_question"
                nil # will ask question
            when "read_file"
                puts "reading #{arguments["file_path"]}"
            when "update_file"
                puts "updating #{arguments["file_path"]}"
            when "create_file"
                puts "creating #{arguments["file_path"]}"
            end
        end

        # default
        @@default_commands = {
            python: "python3",
        }

        def self.python_command
            PairProgrammer::Configuration.python_command || @@default_commands[:python]
        end

        def self.run_shell(command)
            output = ""
            Open3.popen2e(command) do |stdin, stdout_err, wait_thr|
                while line = stdout_err.gets
                    output += line
                end
            end
            output
        end
        
        def self.run(command, arguments)
            case command
            when "update_file"
                file_path = PairProgrammer::Configuration.absolute_path(arguments["file_path"])
                file_content = File.readlines(file_path)
                file_content.insert(arguments["line_number"], arguments["content"])
                File.open(file_path, 'w') do |file|
                    file_content.each { |line| file.puts(line) }
                end
            when "yarn"
                run_shell "cd #{PairProgrammer::Configuration.root} && yarn #{arguments["command"]}"
            when "mv"
                run_shell "cd #{PairProgrammer::Configuration.root} && mv #{arguments["source"]} #{arguments["destination"]}"
            when "python"
                run_shell "cd #{PairProgrammer::Configuration.root} && #{python_command} manage.py #{arguments["command"]}"
            when "ls"
                run_shell "cd #{PairProgrammer::Configuration.root} && ls #{arguments["directory_path"]}"
            when "bundle"
                run_shell "cd #{PairProgrammer::Configuration.root} && bundle #{arguments["command"]}"
            when "rails"
                run_shell "cd #{PairProgrammer::Configuration.root} && rails #{arguments["command"]}"
            when "comment"
                "comment received"
            when "write_file"
                file_path = PairProgrammer::Configuration.absolute_path(arguments["file_path"])
                File.open(file_path, "w") do |file|
                    file.puts(arguments["content"])
                end
            when "create_directory"
                directory_path = PairProgrammer::Configuration.absolute_path(arguments["directory_path"])
                FileUtils.mkdir_p(directory_path)
            when "delete_file"
                file_path = PairProgrammer::Configuration.absolute_path(arguments["file_path"])
                File.delete(file_path)
            when "view_changes"
                # TODO
            when "delete_lines"
                file_path = PairProgrammer::Configuration.absolute_path(arguments["file_path"])
                line_numbers = arguments["line_numbers"]

                # Read the contents of the file into memory
                lines = File.readlines(file_path)

                # Delete the specified lines from the contents
                lines.delete_if.with_index { |line, index| line_numbers.include?(index) }

                # Write the modified contents back to the file
                File.write(file_path, lines.join)
            when "rspec"
                file_path = PairProgrammer::Configuration.absolute_path(arguments["file_path"])
                run_shell "cd #{PairProgrammer::Configuration.root} && rspec #{file_path}}"
            when "ask_question"
                puts arguments["question"]
                STDIN.gets.chomp
            when "read_file"
                file_path = PairProgrammer::Configuration.absolute_path(arguments["file_path"])
                if File.exist?(file_path)
                    File.read(file_path)
                else
                    "file does not exist"
                end
            when "create_file"
                # TODO return response if file is already created
                file_path = PairProgrammer::Configuration.absolute_path(arguments["file_path"])
                FileUtils.touch(file_path)
            else
                raise "Invalid command: #{command}"
            end
        end

        # TODO if a process hangs, ie it asks for user input, need to kill it or let the user interact with it
        def self.run_shell(command)
            logs = ""
            Open3.popen2e(command) do |stdin, stdout_err, wait_thr|
                logs = stdout_err.read
            end
            logs
        end


        def self.insert_content_at_line(file_path, content, line_number)
            # Read the file's content into an array
            file_content = File.readlines(file_path)
        
            # Insert the new content at the desired line number
            file_content.insert(line_number, content)
        
            # Write the modified content back to the file
            File.open(file_path, 'w') do |file|
            file_content.each { |line| file.puts(line) }
            end
        end
    end
end
