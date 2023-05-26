
module PairProgrammer
    module Api
        class Planner
            def self.create(context, requirements)
                body = {
                    context: context,
                    requirements: requirements,
                }
                response = Client.new.post('/api/v1/planner', body)
                response["id"]
            end

            def self.messages(id)
                query = {
                    id: id
                }
                Client.new.get('/api/v1/planner/get_messages', query)
            end

            def self.run(id)
                body = {
                    id: id
                }
                Client.new.post('/api/v1/planner/run', body)
            end

            def self.list
                Client.new.get('/api/v1/planner/list', {})
            end

            def self.respond(id, content)
                body = {
                    id: id,
                    content: content
                }
                Client.new.post('/api/v1/planner/respond', body)
            end

            def self.generate_tasks(id)
                body = {
                    id: id
                }
                Client.new.post('/api/v1/planner/generate_tasks', body)
            end
        end
    end
end