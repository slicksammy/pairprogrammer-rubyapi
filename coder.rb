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
        Client.new.post('/api/v1/coder', body)
    end

    def self.run(id)
        body = {
            id: id
        }
        response = Client.new.post('/api/v1/coder/run', body)
        body = JSON.parse(response.body)
        command_information = body["command"]
        output = Command.run(command_information["command"], command_information["arguments"])
        body = {
            id: id,
            output: output
        }
        Client.new.post('/api/v1/coder/append_output', body)
    end
end