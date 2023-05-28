require_relative 'cli/actions'
require_relative 'pairprogrammer/configuration'
require_relative 'cli/configuration'
require 'optionparser'
require_relative 'cli/display'

command = ARGV.shift

if command == "init"
    Cli::Actions.init
    return
elsif command == "help"
    Cli::Actions.help
    return
end

PairProgrammer::Configuration.root = Cli::Configuration.new.root
PairProgrammer::Configuration.api_key = Cli::Configuration.new.api_key
PairProgrammer::Configuration.python_command = Cli::Configuration.new.python_command

options = {}
case command
when 'coding'
    subcommand = ARGV.shift
    case subcommand
    when "create"
        options[:tasks] = []
        OptionParser.new do |opts|
            opts.banner = "Usage: coder create [options]"

            opts.on('--from_planner', 'Specify id') do |_|
                options[:from_planner] = true
            end

            opts.on('--planner_id ID', 'Specify id') do |planner_id|
                options[:planner_id] = planner_id
            end
        end.parse!

        if options[:from_planner]
            Cli::Actions.create_coder_from_planner(options)
        else
            Cli::Actions.create_coder(options)
        end
    when "run"
        OptionParser.new do |opts|
            opts.banner = "Usage: coder run [options]"

            opts.on('--id ID', 'Specify id') do |id|
                options[:id] = id
            end
        end.parse!

        Cli::Actions.run_coder(options)
    when "list"
        Cli::Actions.list_coders(options)
    else
        Cli::Display.error_message "Invalid subcommand"
        Cli::Actions.help
    end
else
  Cli::Display.error_message "Invalid command"
  Cli::Actions.help
end
