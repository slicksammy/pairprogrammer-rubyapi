require 'yaml'
require 'byebug'

class Settings
    PROJECT_SETTINGS = YAML.load_file("settings.yml").freeze
    
    def self.current_state
        YAML.load_file("current_state.yml")
    end

    def self.root
        PROJECT_SETTINGS["projects"][current_project]["root_path"]
    end

    def self.absolute_path(relative_path)
        File.join(root, relative_path)
    end

    def self.current_project
        ENV["PAIRPROGRAMMER_PROJECT"] || PROJECT_SETTINGS["projects"]["default"]
    end

    def self.current_project=(project)
        if PROJECT_SETTINGS["projects"].keys.include?(project)
            ENV["PAIRPROGRAMMER_PROJECT"] = project
        else
            raise "Project #{project} does not exist"
        end
    end

    def self.current_coder_id=(coder_id)
        project = current_project
        current_state = YAML.load_file("current_state.yml")
        current_state["projects"][project]["coder_id"] = coder_id
        File.open("current_state.yml", "w") { |file| file.write(current_state.to_yaml) }
    end

    def self.current_planner_id=(planner_id)
        project = current_project
        current_state = YAML.load_file("current_state.yml")
        current_state["projects"][project]["planner_id"] = planner_id
        File.open("current_state.yml", "w") { |file| file.write(current_state.to_yaml) }
    end

    def self.current_coder_id
        project = current_project
        current_state = YAML.load_file("current_state.yml")
        current_state["projects"][project]["coder_id"]
    end

    def self.current_planner_id
        project = current_project
        current_state = YAML.load_file("current_state.yml")
        current_state["projects"][project]["planner_id"]
    end

    def self.default_context
        PROJECT_SETTINGS["projects"][current_project]["default_context"]
    end
end