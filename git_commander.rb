require "commander"
require "pry"
require_relative "git_commands/repocleanup"
require_relative "git_commands/redmine_checkout"
require_relative "git_commands/acceptance"
require_relative "git_commands/sdd_jira_checkout"

class GitCommander
  include Commander::Methods

  def run
    program :name,        "Git commander"
    program :version,     "1.0.0"
    program :description, "Helper methods for git repositories maintenance."
    program :help,        "Author", "Roman Simecek <roman@good2go.ch>"

    command :repocleanup do |c|
      c.syntax      = "git repocleanup"
      c.description = "Deletes all branches locally/remote which are fully merged."

      c.action do |args, options|
        GitCommands::Repocleanup.new(Dir.pwd).run
      end
    end

    command :redmine do |c|
      c.syntax      = "git redmine <id>"
      c.description = "Create branches with the redmine id"
      c.option '--engine LIST', Array,   "Define which engines have also be switched"
      c.option '--bundle',      TrueClass, "Run bundle and auto-commit that engine changed to working branch."

      c.action do |args, options|
        options.default(
          bundle: false,
          engine: [],
        )

        GitCommands::RedmineCheckout.new(args.first, options).run
      end
    end

    command :sdd do |c|
      c.syntax      = "git sdd <id>"
      c.description = "Create branches with the SDD-$id from jira"

      c.action do |args, options|
        GitCommands::SDDJiraCheckout.new(args.first, options).run
      end
    end

    command :acceptance do |c|
      c.syntax      = "git acceptance"
      c.description = "Fetch or create the acceptance branch for the current week."
      c.option "--cleanup", TrueClass, "Delete all old acceptance branches."

      c.action do |args, options|
        options.default(cleanup: false)

        GitCommands::Acceptance.new(Dir.pwd, options).run
      end
    end

    command :"redminemerge" do |c|
      c.syntax = "git redmine-merge ids"
      c.description = "Merge all branches with these ids into the current branch."

      c.action do |args, options|
        GitCommands::Redmine::Merger.new(Dir.pwd, args).run
      end
    end

    run!
  rescue Interrupt
    puts
    puts color("WHY???\nThis script was interrupted, but why?", :red)
  end
end
