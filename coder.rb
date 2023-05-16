require_relative 'client'
require_relative 'command'

class Coder
    def self.create(tasks, context, requirements)
        body = {
            tasks: tasks,
            context: context,
            requirements: requirements,
        }
        response = Client.new.post('/api/v1/coder', body)
        response["id"]
    end

    def self.create_from_planner(planner_id)
        body = {
            from_planner: true,
            planner_id: planner_id
        }
        response = Client.new.post('/api/v1/coder', body)
        response["id"]
    end

    def self.run(id)
        body = {
            id: id
        }
        Client.new.post('/api/v1/coder/run', body)
    end

    def self.append_output(id, output)
        body = {
            id: id,
            output: output
        }
        Client.new.post('/api/v1/coder/append_output', body)
    end

    def self.list
        Client.new.get('/api/v1/coder/list', {})
    end

    def self.add_user_message(id, message)
        body = {
            id: id,
            message: message
        }
        Client.new.post('/api/v1/coder/user_message', body)
    end

    def self.append_exception(id, e)
        body = {
            exception: e.class.to_s,
            exception_message: e.message,
            id: id
        }
        Client.new.post('/api/v1/coder/append_exception', body)
    end
end