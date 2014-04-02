module Noteworthy
  class Patterns
    def self.jira
      /(\w{2,4}-\d+)/
    end

    def self.github
      /\#(\d+)/
    end
  end
end