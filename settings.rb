class Settings
    def self.root
        "/Users/sam/Documents/chatgpt/news/mysite/"
    end

    def self.absolute_path(relative_path)
        self.root + relative_path
    end
end