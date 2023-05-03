require_relative 'client'
require_relative 'command'
require 'byebug'
require 'json'

class Coder
    def self.create(tasks, context, requirements)
        body = {
            tasks: tasks,
            context: context,
            requirements: requirements
        }
        response = Client.new.post('/api/v1/coder', body)
        response["id"]
    end

    def self.run(id)
        body = {
            id: id
        }
        response = Client.new.post('/api/v1/coder/run', body)
        command_information = response["command"]
        byebug
        output = Command.run(command_information["command"], command_information["arguments"])
        body = {
            id: id,
            output: output
        }
        Client.new.post('/api/v1/coder/append_output', body)
    end

    def self.list
        coders = Client.new.get('/api/v1/coder/list', {})
        coders.each do |obj|
            puts "#{obj["id"]} - tasks: #{obj["tasks"].join(", ")}"
        end
    end
end