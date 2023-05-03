class Settings
    def self.root
        "/Users/sam/Documents/chatgpt/news/pairprogrammer/"
    end

    def self.absolute_path(relative_path)
        self.root + relative_path
    end
end