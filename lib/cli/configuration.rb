require 'yaml'

module Cli
    class Configuration
        FILE_NAME = ".pear-programmer.yml"

        def self.create(context, api_key, python_command)
            if !["python", "python2", "python3", ""].include?(python_command)
                raise "Invalid python command, please choose python, python2, or python3"
            end
            
            # the version of the configuration file, not cli version
            config = {
                "version" => 1.0,
                "project_settings" => {
                    "context" => context,
                },
                "auth" => {
                    "api_key" => api_key,
                }
            }

            if !python_command.empty?
                config["commands"] = {
                    "python" => python_command
                }
            end

            File.open(File.join(Dir.pwd, FILE_NAME), "w") do |file|
                file.write(config.to_yaml)
            end
        end

        attr_accessor :root
        def initialize
            @root = Dir.pwd
            @configuration_file_path = File.join(@root, FILE_NAME)
            if !File.exists?(@configuration_file_path)
                raise "Pear Programmer configuration file does not exist, please run 'pear-on init' or switch to working directory"
            end
            @configuration_file = YAML.load_file(@configuration_file_path)

            # validations
            if @configuration_file["auth"]&.[]("api_key").nil? || @configuration_file["auth"]["api_key"].empty?
                raise "Pear Programmer api key is missing. Please add your api key to #{@configuration_file_path}"
            end
        end

        def python_command
            command = @configuration_file&.[]("commands")&.[]("python")
            if command.nil? || command.empty?
                nil
            else
                command
            end
        end

        def api_key
            @configuration_file["auth"]["api_key"]
        end

        def default_context
            @configuration_file["project_settings"]["context"]
        end

        private

        def update_file(config)
            File.open(@configuration_file_path, "w") { |file| file.write(config.to_yaml) }
            @configuration_file = config
        end
    end
end