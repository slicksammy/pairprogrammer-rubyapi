require_relative 'settings'
require 'byebug'
require 'fileutils'
require 'open3'

class Command
    def self.run(command, arguments)
        # TODO: move this into each command
        puts "running command #{command} with arguments #{arguments}"
        
        case command
        when "update_file"
            file_path = Settings.absolute_path(arguments["file_path"])
            file_content = File.readlines(file_path)
            file_content.insert(arguments["line_number"], arguments["content"])
            File.open(file_path, 'w') do |file|
                file_content.each { |line| file.puts(line) }
            end
        when "yarn"
            run_shell "cd #{Settings.root} && yarn #{arguments["command"]}"
        when "mv"
            run_shell "cd #{Settings.root} && mv #{arguments["source"]} #{arguments["destination"]}"
        when "python"
            run_shell "cd #{Settings.root} && python3 manage.py #{arguments["command"]}"
        when "ls"
            run_shell "cd #{Settings.root} && ls #{arguments["directory_path"]}"
        when "bundle"
            run_shell "cd #{Settings.root} && bundle #{arguments["command"]}"
        when "rails"
            run_shell "cd #{Settings.root} && rails #{arguments["command"]}"
        when "comment"
            puts arguments["comment"]
        when "write_file"
            file_path = Settings.absolute_path(arguments["file_path"])
            File.open(file_path, "w") do |file|
                file.puts(arguments["content"])
            end
        when "create_directory"
            directory_path = Settings.absolute_path(arguments["directory_path"])
            FileUtils.mkdir_p(directory_path)
        when "delete_file"
            file_path = Settings.absolute_path(arguments["file_path"])
            File.delete(file_path)
        when "view_changes"
            # TODO
        when "delete_lines"
            file_path = Settings.absolute_path(arguments["file_path"])
            line_numbers = arguments["line_numbers"]

            # Read the contents of the file into memory
            lines = File.readlines(file_path)

            # Delete the specified lines from the contents
            lines.delete_if.with_index { |line, index| line_numbers.include?(index) }

            # Write the modified contents back to the file
            File.write(file_path, lines.join)
        when "rspec"
            file_path = Settings.absolute_path(arguments["file_path"])
            run_shell "cd #{Settings.root} && rspec #{file_path}}"
        when "ask_question"
            puts arguments["question"]
            gets.chomp
        when "read_file"
            file_path = Settings.absolute_path(arguments["file_path"])
            if File.exists?(file_path)
                File.read(file_path)
            else
                "file does not exist"
            end
        when "update_file"
            file_path = Settings.absolute_path(arguments["file_path"])

            unless File.exists?(file_path)
                raise "File does not exist: #{file_path}"
            end

            content = arguments["content"]
            line_number = arguments["line_number"]

            # we use append only mode if file is to be written at the end
            if line_number == -1
                File.open(file_path, "a") do |file|
                    file.puts(content)
                end
            else
                insert_content_at_line(file_path, content, line_number)
            end
        when "create_file"
            file_path = Settings.absolute_path(arguments["file_path"])
            FileUtils.touch(file_path)
        else
            raise "Invalid command: #{command}"
        end
    end

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
