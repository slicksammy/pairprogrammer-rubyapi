module PairProgrammer
    class Configuration
        def self.root
            @@root || ENV["PAIRPROGRAMMER_ROOT"]
        end

        def self.api_key
            @@api_key || ENV["PAIRPROGRAMMER_API_KEY"]
        end

        def self.api_key=(api_key)
            @@api_key = api_key
        end

        def self.root=(root)
            @@root = root
        end

        def self.absolute_path(relative_path)
            File.join(root, relative_path)
        end
    end
end