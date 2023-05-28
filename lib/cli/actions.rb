require_relative "../pairprogrammer"
require_relative "display"
# need to require file

# TODO VALIDATIONS
module Cli
    class Actions
        def self.init
            Cli::Display.info_message("creating #{Cli::Configuration::FILE_NAME} in #{Dir.pwd}")
            Cli::Display.info_message("Context is any information about your project that you want the large language model to know about. A few sentences should suffice.")
            Cli::Display.info_message("Include information about your framework (ie Ruby on Rails), your database, how you handle assets, authentication, etc.")
            Cli::Display.info_message("The more detailed you are the better the LLM will perform.")
            context = Cli::Display.get_input("context: ")
            Cli::Display.info_message("If you haven't already, sign up for an API key at https://pairprogrammer.io")
            Cli::Display.info_message("To skip for now and update later press enter")
            api_key = Cli::Display.get_input("api_key: ")
            
            Cli::Configuration.create(context, api_key)
            Cli::Display.success_message("successfully created #{Cli::Configuration::FILE_NAME} - you can update this file at any time")
            Cli::Display.info_message("Please add it to your .gitignore file")
        end

        def self.help

        end

        # CODER
        def self.create_coder(options)
            config = Cli::Configuration.new
            context = Cli::Display.get_input("context (press enter to use default): ")
            if context.empty?
                Cli::Display.info_message("using default context")
                Cli::Display.info_message(config.default_context)
                context = config.default_context
            end
            requirements = Cli::Display.get_input("requirements: ")
            tasks = []
            while true do
                task = Cli::Display.get_input("task (press enter to complete): ")
                if task.empty?
                    break
                else
                    tasks << task
                end
            end

            id = PairProgrammer::Api::Coder.create(tasks, context, requirements)
            config.current_coder_id = id
            puts "Created coding assistant #{id}"
        end

        def self.run_coder(options)
            config = Cli::Configuration.new

            if options[:id]
                id = options[:id]
            else
                Cli::Display.info_message("id not detected, using most recent coding assistant")
                Cli::Display.info_message(config.current_coder_id)
                id = config.current_coder_id
            end

            while true do
                # RETRY when Net::ReadTimeout
                spinner = Cli::Display.spinner
                spinner.auto_spin
                begin
                    response = PairProgrammer::Api::Coder.run(id)
                rescue Net::ReadTimeout
                    Cli::Display.error_message("connection timed out but coder is still running. reconnecting...")
                    next
                ensure
                    spinner.stop()
                end
                
                if response["running"]
                    Cli::Display.info_message("coder is still running, will try again in 20 seconds")
                    sleep(20)
                    next
                elsif response["reached_max_length"]
                    Cli::Display.error_message("conversation has reached its context length due to limitations with LLMs")
                    Cli::Display.error_message("please create a new coder, this coder will no longer be able to run")
                    return
                elsif response["error"]
                    Cli::Display.error_message("there was an error processing the assistant's response")
                    Cli::Display.info_message("retrying...")
                    next
                end

                if response["available_tokens"] && response["available_tokens"] < 500
                    Cli::Display.info_message("conversation is getting long and approaching context length limit")
                    Cli::Display.info_message("this conversation has #{response["available_tokens"]} tokens left")
                end

                system_message = response["system_message"]

                response_required = true
                # TODO if there is explanation but no command then response is required
                if system_message["explanation"] && !system_message["explanation"].empty?
                    Cli::Display.message("assistant", system_message["explanation"])
                end

                if system_message["command"]
                    skip_command = false
                    command_display = PairProgrammer::Command.display_command(system_message["command"], system_message["arguments"])
                    Cli::Display.info_message(command_display) if command_display
                    response_required = false
                    # command overwrites
                    if system_message["command"] == "comment"
                        Cli::Display.message("assistant", system_message["arguments"]["comment"])
                        response_required = true
                    elsif system_message["command"] == "ask_question"
                        Cli::Display.message("assistant", system_message["arguments"]["question"])
                        response_required = true
                    else
                        if system_message["command"] == "write_file"
                            # this fails if file doesn't exist
                            file_path = PairProgrammer::Configuration.absolute_path(system_message["arguments"]["file_path"])
                            begin
                                original_content = File.read(file_path)
                            rescue Errno::ENOENT
                                Cli::Display.error_message("there was an error running the command, notifying assistant of error.")
                                PairProgrammer::Api::Coder.append_exception(id, e)
                                Cli::Display.info_message("retrying...")
                                next
                            end
                            
                            Cli::Display.dispaly_diff(original_content, system_message["arguments"]["content"])

                            while true do
                                confirmation = Cli::Display.get_input("y/n to accept changes: ")
                                if confirmation.empty?
                                    next
                                elsif !confirmation.downcase.start_with?("y")
                                    Cli::Display.info_message("changes rejected")
                                    # PairProgrammer::Api::Coder.append_output(id, "COMMAND REJECTED")
                                    skip_command = true
                                    response_required = true
                                    break
                                else
                                    Cli::Display.info_message("changes accepted")
                                    break
                                end
                            end
                        end

                        if !skip_command
                            output = nil
                            begin
                                output = PairProgrammer::Command.run(system_message["command"], system_message["arguments"])
                            rescue => e
                                Cli::Display.error_message("there was an error running the command, notifying assistant of error.")
                                PairProgrammer::Api::Coder.append_exception(id, e)
                                Cli::Display.info_message("retrying...")
                                next
                            end
                            PairProgrammer::Api::Coder.append_output(id, output)
                        end
                    end
                end

                while true do
                    display = response_required ? "required" : "optional"
                    message = Cli::Display.get_input("response (#{display}): ")
                    if message.empty?
                        if response_required
                            Cli::Display.error_message("response required")
                            next
                        else
                            break
                        end
                    else
                        PairProgrammer::Api::Coder.add_user_message(id, message)
                        response_required = false
                    end
                end
            end
        end

        def self.list_coders(options)
            coders = Coder.list
            coders.each do |obj|
                puts "#{obj["id"]} - requirements #{obj["requirements"]} - tasks: #{obj["tasks"].join(", ")}"
            end
        end
    end
end