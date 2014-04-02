require 'jiralicious'

module Noteworthy
  class Jira
    attr_accessor :configured
    
    def configure(config=nil)
      @configured = false
      return false if config.nil?
      Jiralicious.configure do |c|
        c.username = ENV["JIRA_USER"]
        c.password = ENV["JIRA_PASS"]
        c.uri = config['jira']
        c.api_version = "latest"
        c.auth_type = :basic
      end
      @configured = true
    end
    
    def get_issue(key=nil)
      return false if key.nil?
      return false unless self.configured?
      return Jiralicious::Issue.find(key)
    end
    
    def configured?
      return false unless @configured
      @configured
    end
  end
end
