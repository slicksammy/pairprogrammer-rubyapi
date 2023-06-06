require_relative 'client'

module PairProgrammer
    module Api
        class System
            def self.versions
                Client.new.get('/api/v1/versions', {})
            end

            def self.client_exception(command, exception, version)
                body = {
                    command: command,
                    exception: exception.class.to_s,
                    message: exception.message,
                    backtrace: exception.backtrace,
                    version: version
                }
                Client.new.post('/api/v1/client_exception', body)
            end
        end
    end
end
