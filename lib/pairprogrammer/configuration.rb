module PairProgrammer
    class Configuration
        def self.root
            @@root || ENV["PEAR_PROGRAMMER_ROOT"]
        end

        def self.api_key
            @@api_key || ENV["PEAR_PROGRAMMER_API_KEY"]
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

        def self.python_command
            @@python_command
        end

        def self.python_command=(python_command)
            available_commands = ["python", "python2", "python3"]
            if available_commands.include?(python_command)
                @@python_command = python_command
            else
                raise "Invalid python command - #{python_command} - command must be one of #{available_commands}"
            end
        end
    end
end