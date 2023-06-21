require 'colorize'
require 'tty-spinner'
require 'diffy'
require 'terminal-table'
require 'tty-prompt'

module Cli
    class Display
        def self.message(role, content)
            if role == "user"
                puts("you".colorize(background: :green) + ": " + content)
            else
                puts("assistant".colorize(background: :yellow) + ": " + content)
            end
        end

        def self.table(rows, headers)
            rows = rows.map(&:values)        
            table = Terminal::Table.new(
              headings: headers,
              rows: rows
            )

            puts table
        end

        def self.select(title, options)
            prompt = TTY::Prompt.new
            prompt.select(title.colorize(mode: :bold), options, per_page: 100, columnize: 2)
        end

        def self.confirmation(title)
            while true do
                puts(title.colorize(mode: :bold))
                print("y/N: ".colorize(mode: :bold))
                response = STDIN.gets.chomp.downcase

                if response.empty?
                    puts("Response required".colorize(:red))
                elsif response == "y"
                    return true
                elsif response == "n"
                    return false
                else
                    puts("Invalid response. Must be one letter, case insenstive".colorize(:red))
                end
            end
        end

        def self.get_input(input)
            print(input.colorize(mode: :bold))
            STDIN.gets&.chomp || ''
        end

        def self.success_message(message)
            puts(message.colorize(:green))
        end

        def self.error_message(message)
            puts(message.colorize(:red))
        end

        def self.info_message(message)
            puts(message.colorize(color: :light_black))
        end

        def self.spinner(title="running")
            TTY::Spinner.new("[:spinner] #{title}", format: :spin_2)
        end

        def self.dispaly_diff(original_content, new_content)
            Diffy::Diff.new(original_content, new_content, source: 'strings').each do |line|
                if line.start_with?("+")
                    puts line.colorize(:green)
                elsif line.start_with?("-")
                    puts line.colorize(:red)
                else
                    puts line
                end
            end
        end
    end
end