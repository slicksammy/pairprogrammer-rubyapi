class Display
    def self.message(role, content)
        role = "you" if role == "user"
        puts("#{role}: #{content}")
    end
end