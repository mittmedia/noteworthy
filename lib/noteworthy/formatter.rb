module Noteworthy
  class Formatter
    attr_accessor :h3, :h4, :bull, :link, :format, :filext
    
    def initialize
      self.format = "markdown"
      self.h3 = "###"
      self.h4 = "####"
      self.bull = " *"
      self.link = {:text_b => '[', :text_a => ']', :link_b => '(', :link_a => ')'}
      self.filext = 'md'
    end
    
    def define_format(format="markdown")
      if format == "markdown"
        self.h3 = "###"
        self.h4 = "####"
        self.bull = " *"
        self.link = {:text_b => '[', :text_a => ']', :link_b => '(', :link_a => ')'}
        self.filext = 'md'
      elsif format == "textile"
        self.h3 = "h3."
        self.h4 = "h4."
        self.bull = " *"
        self.link = {:text_b => '"', :text_a => '":', :link_b => '', :link_a => ''}
        self.filext = 'textile'
      end
    end
  end
end