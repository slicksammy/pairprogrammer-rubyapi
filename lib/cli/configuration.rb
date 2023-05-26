require 'yaml'

module Cli
    class Configuration
        @@project_settings = YAML.load_file("lib/cli/configuration.yml")

        def self.api_key
            @@project_settings["api_key"]
        end

        def self.current_state
            YAML.load_file("lib/cli/current_state.yml")
        end

        def self.root
            @@project_settings["projects"][current_project]["root_path"]
        end

        def self.current_project
            ENV["PAIRPROGRAMMER_PROJECT"] || @@project_settings["projects"]["default"]
        end

        def self.current_project=(project)
            if @@project_settings["projects"].keys.include?(project)
                ENV["PAIRPROGRAMMER_PROJECT"] = project
            else
                raise "Project #{project} does not exist"
            end
        end

        def self.current_coder_id=(coder_id)
            project = current_project
            new_state = current_state
            new_state["projects"][project]["coder_id"] = coder_id
            File.open("lib/cli/current_state.yml", "w") { |file| file.write(new_state.to_yaml) }
        end

        def self.current_planner_id=(planner_id)
            project = current_project
            new_state = current_state
            new_state["projects"][project]["planner_id"] = planner_id
            File.open("lib/cli/current_state.yml", "w") { |file| file.write(new_state.to_yaml) }
        end

        def self.current_coder_id
            project = current_project
            current_state["projects"][project]["coder_id"]
        end

        def self.current_planner_id
            project = current_project
            current_state["projects"][project]["planner_id"]
        end

        def self.default_context
            @@project_settings["projects"][current_project]["default_context"]
        end
    end
end