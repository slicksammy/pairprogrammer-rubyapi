require_relative 'client'

module PairProgrammer
    module Api
        class Version
            def self.versions
                Client.new.get('/api/v1/versions', {})
            end
        end
    end
end