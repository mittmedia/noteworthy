module Noteworthy
  class Config
    def self.parse
      wanted = File.join(Dir.pwd, 'config', 'noteworthy.yml')
      thing = nil
      unless File.exist?(wanted)
        wanted = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'noteworthy.yml'))
      end
      return YAML.load_file(wanted)
    end
  end
end