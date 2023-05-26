require 'colorize'
require 'tty-spinner'
# require 'diff/lcs'
require 'diffy'

module Cli
    class Display
        def self.message(role, content)
            if role == "user"
                puts("you".colorize(background: :green) + ": " + content)
            else
                puts("assistant".colorize(background: :yellow) + ": " + content)
            end
        end

        def self.get_input(input)
            print(input.colorize(mode: :bold))
            gets.chomp
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