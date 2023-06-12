require_relative "../pairprogrammer"
require_relative "display"
require_relative "version"
# need to require file

# TODO VALIDATIONS
module Cli
    class Actions
        def self.init
            Cli::Display.info_message("Welcome to Pear Programmer!")
            confirmation = Cli::Display.confirmation("Are you in the root directory of your project?")
            if !confirmation
                Cli::Display.error_message("Please change directory into the root of your project and try again.")
                return
            end
                
            Cli::Display.info_message("creating #{Cli::Configuration::FILE_NAME} in #{Dir.pwd}")
            Cli::Display.info_message("Context is any information about your project that you want the large language model to know about. A few sentences should suffice.")
            Cli::Display.info_message("Include information about your framework (ie Ruby on Rails), your database, how you handle assets, authentication, etc.")
            Cli::Display.info_message("The more detailed you are the better the LLM will perform.")
            context = Cli::Display.get_input("context: ")
            
            Cli::Display.info_message("If you haven't already, sign up for an API key at https://pairprogrammer.io")
            Cli::Display.info_message("To skip for now and update later press enter")
            api_key = Cli::Display.get_input("api_key: ")
            
            Cli::Display.info_message("If you are running a python app, which python binary are you using? (python, python2, python3)")
            Cli::Display.info_message("If you are not using python, press enter to skip")
            python_command = Cli::Display.select("python command: (choose none if you are not using python)", {"python" => "python", "python2" => "python2", "python3" => "python3", "none" => ""})
            
            Cli::Configuration.create(context, api_key, python_command)
            Cli::Display.success_message("successfully created #{Cli::Configuration::FILE_NAME} - you can update this file at any time")
            Cli::Display.info_message("Please add it to your .gitignore file")
        end

        def self.check_cli_version
            versions = PairProgrammer::Api::System.versions
            if versions["cli"] != Cli::Version::VERSION
                Cli::Display.info_message("A new version of the CLI is available, installing update")
                gem = PairProgrammer::Configuration.development? ? "pear-programmer-0.1.gem" : "pear-programmer"
                Cli::Display.info_message("Running gem update #{gem}")
                system("gem update #{gem}")
                Cli::Display.success_message("Update complete")
            end
        end

        def self.report_exception(command, e)
            version = Cli::Version::VERSION
            PairProgrammer::Api::System.client_exception(command, e, version)
            Cli::Display.error_message("An error occurred")
            Cli::Display.error_message(e.message)
        end

        def self.help
            Cli::Display.info_message "Available Commands:"
            Cli::Display.info_message "  init - initialize pear-programmer from the root of your project"
            Cli::Display.info_message "  help"
            Cli::Display.info_message "  coding (new|start|list)"
        
            Cli::Display.info_message "Usage examples:"
            Cli::Display.info_message "  pear-on init"
            Cli::Display.info_message "  pear-on help"
            Cli::Display.info_message "  pear-on coding new (define a new set of requirements and tasks)"
            Cli::Display.info_message "  pear-on coding start (-a, --auto | will prompt you only when required)"
            Cli::Display.info_message "  pear-on coding list (list all requirements)"
        end

        # CODER
        def self.create_coder(options)
            config = Cli::Configuration.new
            # context = Cli::Display.get_input("context (press enter to use context from your #{Cli::Configuration::FILE_NAME} file): ")
            # if context.empty?
            Cli::Display.info_message("using context from your #{Cli::Configuration::FILE_NAME} file:")
            Cli::Display.info_message(config.default_context)
            context = config.default_context
            # end
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
            Cli::Display.success_message("Done")
            Cli::Display.info_message("You can now run pear-on coding start")
        end

        def self.run_coder(options)
            config = Cli::Configuration.new
            auto = !!options[:auto]

            if options[:id]
                id = options[:id]
            else
                coders = PairProgrammer::Api::Coder.list
                id = Cli::Display.select("Select which requirements you would like to work on", coders.inject({}) { |hash, coder| hash[coder["requirements"]] = coder["id"]; hash })
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
                    Cli::Display.info_message("assistant is still running, will try again in 20 seconds")
                    sleep(20)
                    next
                elsif response["reached_max_length"]
                    Cli::Display.error_message("conversation has reached its context length due to limitations with LLMs")
                    Cli::Display.error_message("please create a new set of requirements")
                    return
                elsif response["error"]
                    Cli::Display.error_message("there was an error processing the assistant's response")
                    Cli::Display.info_message("retrying in 5 seconds")
                    sleep(5)
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
                            rescue Errno::ENOENT => e
                                Cli::Display.error_message("there was an error running the command, notifying assistant of error.")
                                PairProgrammer::Api::Coder.append_exception(id, e)
                                Cli::Display.info_message("retrying...")
                                next
                            end
                            
                            Cli::Display.dispaly_diff(original_content, system_message["arguments"]["content"])
                            
                            confirmation = Cli::Display.confirmation("Accept changes?")
                            if !confirmation
                                Cli::Display.info_message("changes rejected")
                                # PairProgrammer::Api::Coder.append_output(id, "COMMAND REJECTED")
                                skip_command = true
                                response_required = true
                            else
                                Cli::Display.info_message("changes accepted")
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
                    # user does not have to respond if auto is true
                    if !response_required && auto
                        break
                    end

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
            coders = PairProgrammer::Api::Coder.list
            Cli::Display.table(coders, ["id", "tasks", "requirements", "created_at"])
        end
    end
end