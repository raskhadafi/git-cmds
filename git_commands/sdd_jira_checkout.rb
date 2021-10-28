require "yaml"
require_relative "bundler"
require_relative "git_repository"

module GitCommands
  class SDDJiraCheckout
    extend Forwardable

    BranchTypes = %w[
      b(ug)
      c(hore)
      e(pic)
      f(eature)
      r(elease)
      s(print)
    ]

    attr_accessor :git_repo

    def initialize(jira_id, options)
      @working_dir = Pathname.new(Dir.pwd)
      @git_repo    = GitRepository.new(@working_dir)
      @jira_id     = "SDD-#{jira_id}"
    end

    def run
      unless git_repo.clean?
        puts "Repo is not clean! Please commit or whatever before proceeding."
        return
      end

      redmine_branch = fetch_redmine_branch
      branch_creator = "RS".freeze

      if redmine_branch && git_repo.exists_branch_local?(redmine_branch)
        git_repo.checkout(redmine_branch.name)
      elsif redmine_branch && git_repo.exists_branch_remote?(redmine_branch)
        `git checkout #{redmine_branch.name.gsub("origin/", "")}`
      else
        branch_name = fetch_redmine_branch_name(branch_creator)

        git_repo.create_branch(branch_name)
        `git checkout #{branch_name}`
      end
    end

    private

    def fetch_redmine_branch
      git_repo.branches.find { |branch| branch.name.include?(@jira_id) }
    end

    def fetch_redmine_branch_name(branch_creator)
      [
        ask_for_branch_type,
        @jira_id,
        branch_creator,
        ask_for_branch_hint
      ].compact.join("-")
    end

    def ask_for_branch_hint
      ask("Your feature description: ") { |q| q.validate = /.{2,}/ }
    end

    def ask_for_branch_type
      choose { |menu|
        menu.prompt = "What is it?"
        menu.choices(*BranchTypes)
      }[0]
    end
  end
end
