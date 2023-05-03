require 'optparse'
require_relative 'coder'

command = ARGV.shift
options = {}
case command
when 'coder'
    subcommand = ARGV.shift
    case subcommand
    when "create"
        options[:tasks] = []
        OptionParser.new do |opts|
            # Set the banner attribute
            opts.banner = "Usage: coder create [options]"
          
            # Define the -t or --tasks option
            opts.on('-t', '--tasks TASK', 'Specify tasks') do |task|
              options[:tasks] << task
            end
            
            opts.on('-c', '--context CONTEXT', 'Specificy context') do |context|
                options[:context] = context
            end

            opts.on('-r', '--requirements REQUIREMENTS', 'Specifiy requirements') do |requirements|
                options[:requirements] = requirements
            end
        end.parse!

        Coder.create(options[:tasks], options[:context], options[:requirements])
    when "run"
        OptionParser.new do |opts|
            # Set the banner attribute
            opts.banner = "Usage: coder create [options]"

            opts.on('--id ID', 'Specify id') do |id|
                options[:id] = id
            end
        end.parse!
        
        puts(options[:id])
        Coder.run(options[:id])
    end
else
  puts 'Invalid command! Use `pairprogrammer help` for more information.'
end
