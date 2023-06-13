require_relative 'cli/actions'
require_relative 'pairprogrammer/configuration'
require_relative 'cli/configuration'
require 'optionparser'
require_relative 'cli/display'


command = ARGV[0]

if command == "init"
    Cli::Actions.init
    return
elsif command == "help"
    Cli::Actions.help
    return
end

config = Cli::Configuration.new
PairProgrammer::Configuration.root = config.root
PairProgrammer::Configuration.api_key = config.api_key

begin
    if config.python_command
        PairProgrammer::Configuration.python_command = config.python_command
    end

    Cli::Actions.check_cli_version

    options = {}
    case command
    when 'coding'
        subcommand = ARGV[1]
        case subcommand
        when "new"
            Cli::Actions.create_coder(options)
        when "start"
            OptionParser.new do |opts|
                opts.banner = "Usage: coder run [options]"

                opts.on('-a', '--auto', 'Specify auto') do
                    options[:auto] = true
                end
            end.parse!

            Cli::Actions.run_coder(options)
        when "list"
            Cli::Actions.list_coders(options)
        else
            Cli::Display.error_message "Invalid coding command"
            Cli::Actions.help
        end
    else
        Cli::Display.error_message "Invalid command"
        Cli::Actions.help
    end
rescue => e
    # TODO: log ruby version too
    Cli::Actions.report_exception(ARGV.join(" "), e)
end

