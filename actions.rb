require_relative 'coder'
require_relative 'planner'
require_relative 'display'
require 'byebug'

# TODO VALIDATIONS
class Actions
    # SETTINGS
    def self.update_settings(options)
        puts Settings.current_project
        if options[:project]
            puts "updating project to #{options[:project]}"
            Settings.current_project = options[:project]
        end
    end
    # PLANNER
    def self.create_planner(options)
        puts("creating planner")
        if options[:context] 
            context = options[:context]
        else
            puts("context not detected, using default context")
            context = Settings.default_context
        end
        id = Planner.create(context, options[:requirements])
        puts("created planner with id #{id}")
        puts("setting current_planner_id #{id}")
        Settings.current_planner_id = id
    end

    def self.view_planner_messages(options)
        if options[:id]
            id = options[:id]
        else
            puts("id not detected, using current_planner_id")
            id = Settings.current_planner_id
        end
        Planner.messages(id).each { |m| Display.message(m["role"], m["content"])}
    end

    def self.list_planners(options)
        puts Planner.list
    end

    def self.run_planner(options)
        if options[:id]
            id = options[:id]
        else
            puts("id not detected, using current_planner_id")
            id = Settings.current_planner_id
        end
        
        puts Planner.run(id)
    end

    def self.run_planner(options)
        if options[:id]
            id = options[:id]
        else
            puts("id not detected, using current_planner_id")
            id = Settings.current_planner_id
        end

        Planner.run(id)
        Planner.messages(id).each { |m| Display.message(m["role"], m["content"]) }

        while true do
            print "you: "
            message = gets.chomp
            Planner.respond(id, message)
            assistant_message = Planner.run(id)
            Display.message("assistant", assistant_message["content"])
        end
    end

    def self.generate_planner_tasks(options)
        if options[:id]
            id = options[:id]
        else
            puts("id not detected, using current_planner_id")
            id = Settings.current_planner_id
        end

        puts Planner.generate_tasks(id)
    end

    # CODER
    def self.create_coder(options)
        print("context (press enter to use default): ")
        context = gets.chomp
        if context.empty?
            puts("context not detected, using default context")
            context = Settings.default_context
        end
        print("requirements: ")
        requirements = gets.chomp
        tasks = []
        while true do
            print("task (press enter to complete): ")
            task = gets.chomp
            if task.empty?
                break
            else
                tasks << task
            end
        end

        id = Coder.create(tasks, context, requirements)
        Settings.current_coder_id = id
        puts "Coder created with id #{id}"
    end

    def self.create_coder_from_planner(options)
        puts("creating coder from planner")
        if options[:planner_id] 
            planner_id = options[:planner_id]
        else
            puts("planner_id not detected, using current_planner_id")
            planner_id = Settings.current_planner_id
        end
        id = Coder.create_from_planner(planner_id)
        Settings.current_coder_id = id
        puts "Coder created with id #{id}"
    end

    def self.run_coder(options)
        if options[:id]
            id = options[:id]
        else
            puts("id not detected, using current_coder_id")
            id = Settings.current_coder_id
        end
        
        command_information = Coder.run(id)
        output = Command.run(command_information["command"], command_information["arguments"])
        Coder.append_output(id, output)
    end

    def self.run_coder_interactive(options)
        if options[:id]
            id = options[:id]
        else
            puts("id not detected, using current_coder_id")
            id = Settings.current_coder_id
        end

        while true do
            # RETRY when Net::ReadTimeout
            response = Coder.run(id)
            if response["running"]
                sleep(20)
                next
            end

            if response["error"]
                next
            end

            system_message = response["system_message"]

            if system_message["explanation"]
                Display.message("assistant", system_message["explanation"])
            end

            if system_message["command"]
                begin
                    output = Command.run(system_message["command"], system_message["arguments"])
                    Coder.append_output(id, output)
                rescue => e
                    print("exception: #{e.message}")
                    Coder.append_exception(id, e)
                end
            end

            while true do
                print "you (press enter to skip): "
                message = gets.chomp
                if message.empty?
                    break
                else
                    Coder.add_user_message(id, message)
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