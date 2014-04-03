require "noteworthy/version"
require "noteworthy/config"
require "noteworthy/formatter"
require "noteworthy/patterns"
require "noteworthy/jira"
require "git"
require 'rake'
require 'rake/tasklib'
require 'yaml'

module Noteworthy
  class Tasks < ::Rake::TaskLib
    def initialize(namespace = :releasenote)
    
      namespace(namespace) do
        desc "Generate Release Notes"
        task :generate, :until, :since do |t, args|
          config = Noteworthy::Config.parse

          formatter = Noteworthy::Formatter.new
          formatter.define_format config["format"]

          get_log config, args, formatter
        end
      end
    end
    
    private
    
    def open_repo
      return Git.open(Dir.pwd)
    end
    
    def get_remote
      git = open_repo
      gh_repo_pat = /git@github\.com\:(\w.+\w)\.git/
      remote_origin = git.remote('origin').url
      remote = false
      
      if remote_origin =~ gh_repo_pat
        remote = "https://github.com/#{remote_origin.sub(gh_repo_pat, '\1')}"
      end
      return remote
    end
    
    def highlight_commit_message(commit_message, config, formatter=nil)
      jira_inst = config["jira"]
      github_repo = config["github_repo"] || get_remote
      formatter = Noteworthy::Formatter.new if formatter.nil?
      link = formatter.link
      
      if commit_message =~ Noteworthy::Patterns.jira
        @issues.push(commit_message.match(Noteworthy::Patterns.jira)[0]) unless @issues.include?(commit_message.match(Noteworthy::Patterns.jira)[0])
        
        if jira_inst
          commit_message = commit_message.sub(Noteworthy::Patterns.jira, "[#{link[:text_b]}"+'\1'+"#{link[:text_a]}#{link[:link_b]}#{jira_inst}/browse/"+'\1'+"#{link[:link_a]}]")
        else
          commit_message = commit_message.sub(Noteworthy::Patterns.jira, '[\1]')
        end
      end
      
      if commit_message =~ Noteworthy::Patterns.github
        if github_repo
          commit_message = commit_message.sub(Noteworthy::Patterns.github, "[#{link[:text_b]}\#"+'\1'+"#{link[:text_a]}#{link[:link_b]}#{github_repo}/issues/"+'\1'+"#{link[:link_a]}]")
        else
          commit_message = commit_message.sub(Noteworthy::Patterns.github, '[#\1]')
        end
      end
      
      return commit_message
    end
    
    def get_log(config,args,formatter=nil)
      git = open_repo
      jira_inst = config["jira"]
      github_repo = config["github_repo"] || get_remote
      github_link_commit = config["link_commit"] || false
      author_email = config["author_email"]
      show_author = config["show_author"]
      long_hash = config["long_hash"]
      date = config['show_date']
      log_until = args[:until] || nil
      log_since = args[:since] || nil
      formatter = Noteworthy::Formatter.new if formatter.nil?
      
      jira_pat = Noteworthy::Patterns.jira
      github_pat = Noteworthy::Patterns.github
      if log_until
        if log_since
          gitlog = git.log.between(log_since.to_s, log_until.to_s)
        else
          gitlog = git.log.until(log_until.to_s)
        end
        puts "#{formatter.h3} Version #{log_until}"
      else
      gitlog = git.log
      puts "#{formatter.h3} Release Notes"
      end
      
      @issues = []
      @entries = []
      link = formatter.link
      gitlog.each do |commit|
        commit_message = commit.message
        commit_date = "[#{commit.date.iso8601}]"
        unless date
          commit_date = ''
        end
        
        if show_author
          author = "__#{commit.author.name} (#{commit.author.email})__"
        else
          author = ''
        end
        
        commit_message = highlight_commit_message(commit_message, config, formatter)

        sha = commit.sha
        longsha = sha
        sha = sha[0..6] unless long_hash
        
        if github_link_commit && github_repo
          sha = "[#{link[:text_b]}#{sha}#{link[:text_a]}#{link[:link_b]}#{github_repo}/commit/#{longsha}#{link[:link_a]}]"
        else
          sha = "[#{sha}]"
        end
        
        
        tagged = false
        if commit_message !~ /Merge/
          if commit_message.match(Noteworthy::Patterns.jira)
            tagged = commit_message.match(Noteworthy::Patterns.jira)[0]
          end
          @entries.push({:string => " #{formatter.bull} #{sha} #{commit_message} #{author} #{commit_date}", :tagged => tagged})
        end
        
      end
      
      jira_client = Noteworthy::Jira.new
      jira_client.configure(config) if config['connect_jira']
      
      @issues.each do |i|
        key = i.sub(Noteworthy::Patterns.jira, '\1')
        issue = jira_client.get_issue(key)
        parent = nil
        if issue and issue.fields.fields_current.has_key?('parent')
          parent = jira_client.get_issue(issue.fields.fields_current['parent']['key'])
        end
        summary = ''
        type = ''
        if issue
          summary = ": #{issue.fields.fields_current['summary']}"
          type = "#{issue.fields.fields_current['issuetype']['name']} "
        end
        unless parent.nil?
          puts "\n#{formatter.h4} #{parent.fields.fields_current['issuetype']['name']} #{issue.fields.fields_current['parent']['key'].sub(Noteworthy::Patterns.jira, link[:text_b]+'\1'+link[:text_a]+link[:link_b]+jira_inst+'/browse/\1'+link[:link_a])}#{parent.fields.fields_current['summary']}"
          puts "\n#{formatter.h5} #{type}#{i.sub(Noteworthy::Patterns.jira, link[:text_b]+'\1'+link[:text_a]+link[:link_b]+jira_inst+'/browse/\1'+link[:link_a])}#{summary}"
        else
          puts "\n#{formatter.h4} #{type}#{i.sub(Noteworthy::Patterns.jira, link[:text_b]+'\1'+link[:text_a]+link[:link_b]+jira_inst+'/browse/\1'+link[:link_a])}#{summary}"
        end
        @entries.each do |e|
          puts e[:string] if e[:tagged] == i
        end
      end
      puts "\n#{formatter.h4} Other Commits"
      @entries.each do |e|
        puts e[:string] if !e[:tagged]
      end
    end
    
  end
end
