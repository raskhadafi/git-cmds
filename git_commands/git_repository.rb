require "rugged"
require "forwardable"
require "pathname"

module GitCommands
  class GitRepository
    extend Forwardable

    IgnoredFileStates = %i[
      ignored
      worktree_new
    ]

    attr_accessor :git, :path

    def_delegators :@git, :branches, :log, :branch, :push, :commit, :add, :status, :remote, :checkout, :create_branch, :delete

    class NotImplementedYetError < StandardError; end

    def initialize(path)
      @path = Pathname.new(path)
      @git  = Rugged::Repository.new(path.to_s)
    end

    def clean?
      file_states.empty?
    end

    def current_branch
      @git.head.name.sub(/^refs\/heads\//, '')
    end

    def is_fully_merged?(first_sha, second_sha)
bindig.pry
      raise NotImplementedYetError

      log.between(first_sha, second_sha).size == 0
    end

    def delete_remote_branch(branch_name)
      raise NotImplementedYetError

      branch(branch.name).delete
      push("origin", ":#{branch_name}", {"-u" => nil}) if exists_branch_remote?(branch_name)
    end

    %i[local remote].each { |branch_location|
      private

      define_method("#{branch_location}_branch_names") {
        branches.each_name(branch_location).to_a
      }

      public

      define_method("exists_branch_#{branch_location}?") { |branch|
        eval("#{branch_location}_branch_names").include?(branch.respond_to?(:name) ? branch.name : branch)
      }

      define_method("#{branch_location}_branch_names_include?") { |value|
        send("#{branch_location}_branch_names").grep(value)
      }
    }

    private

    def file_states
      file_states = []

      status { |file, status_data| file_states << status_data }

      file_states.flatten!
      file_states.uniq!
      file_states.reject! { |e| IgnoredFileStates.include?(e) }

      file_states
    end

  end
end
