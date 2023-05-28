require 'yaml'

module Cli
    class Configuration
        FILE_NAME = ".pear-programmer.yml"

        def self.create(context, api_key)
            File.open(File.join(Dir.pwd, FILE_NAME), "w") do |file|
                file.write({
                    "version" => 1.0,
                    "project_settings" => {
                        "context" => context,
                    },
                    "auth" => {
                        "api_key" => api_key,
                    }
                }.to_yaml)
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
        end

        def api_key
            @configuration_file["auth"]["api_key"]
        end

        def current_coder_id=(coder_id)
            @configuration_file["project_settings"]["coder_id"] = coder_id
            update_file(@configuration_file)
        end

        def current_coder_id
            @configuration_file["project_settings"]["coder_id"]
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