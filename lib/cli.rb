require_relative 'cli/actions'
require_relative 'pairprogrammer/configuration'
require_relative 'cli/configuration'
require 'optionparser'
require_relative 'cli/display'

command = ARGV.shift

if command == "init"
    Cli::Actions.init
    return
end

PairProgrammer::Configuration.root = Cli::Configuration.new.root
PairProgrammer::Configuration.api_key = Cli::Configuration.new.api_key

options = {}
case command
when 'settings'
    OptionParser.new do |opts|
        opts.banner = "Usage: coder create [options]"
        
        opts.on('-p', '--project PROJECT', 'Specificy project') do |project|
            options[:project] = project
        end
    end.parse!

    Cli::Actions.update_settings(options)
when 'planner'
    subcommand = ARGV.shift
    case subcommand
    when "list"
        Cli::Actions.list_planners(options)
    when "create"
        puts "Enter requirements:"
        requirements = STDIN.gets.chomp
        options[:requirements] = requirements
        Cli::Actions.create_planner(options)
    when "messages"
        OptionParser.new do |opts|
            opts.banner = "Usage: planner messages [options]"

            opts.on('--id ID', 'Specify id') do |id|
                options[:id] = id
            end
        end.parse!

        Cli::Actions.view_planner_messages(options) 
    when "run"
        OptionParser.new do |opts|
            opts.banner = "Usage: planner messages [options]"
            
            opts.on('--id ID', 'Specify id') do |id|
                options[:id] = id
            end
        end.parse!

        Cli::Actions.run_planner(options)
    when "generate_tasks"
        OptionParser.new do |opts|
            opts.banner = "Usage: planner generate_tasks [options]"

            opts.on('--id ID', 'Specify id') do |id|
                options[:id] = id
            end
        end

        Cli::Actions.generate_planner_tasks(options)
    end
when 'coder'
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

            opts.on('-i', 'Run interactive') do |_|
                options[:interactive] = true
            end
        end.parse!

        if options[:interactive]
            Cli::Actions.run_coder_interactive(options)
        else
            Cli::Actions.run_coder(options)
        end
    when "list"
        Cli::Actions.list_coders(options)
    end
else
  puts 'Invalid command! Use `pairprogrammer help` for more information.'
end
