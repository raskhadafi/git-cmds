require "yaml"
require "forwardable"
require_relative "bundler"
require_relative "git_repository"

module GitCommands
  class RedmineCheckout
    extend Forwardable

    def_delegators :@bundler, :gemfile, :bundle, :update_engines #, :add_engines_to_bunder_config

    BranchTypes = %w[
      b(ug)
      c(hore)
      e(pic)
      f(eature)
      r(elease)
      s(print)
    ]

    attr_accessor :git_repo

    def initialize(redmine_id, options)
      @working_dir    = Pathname.new(Dir.pwd)
      @git_repo       = GitRepository.new(@working_dir)
      @redmine_id     = redmine_id
      @engines        = options.engine
      @run_bundle     = options.bundle
      @bundler        = Bundler.new(@working_dir)
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
      git_repo.branches.find { |branch| branch.name.include?(@redmine_id) }
    end

    def fetch_redmine_branch_name(branch_creator)
      [
        ask_for_branch_type,
        @redmine_id,
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
