require_relative "git_repository"

module GitCommands
  class Acceptance
    include Commander::UI

    attr_accessor :path, :today, :git

    def initialize(path, options)
      @path  = path
      @git   = GitRepository.new(@path)
      @today = Date.today
      @options = options
    end

    def run
      return color("Your repo is not clean!!\nAborting ...............", :red) unless git.clean?

      if git.exists_branch_local?(acceptance_branch_name) || git.exists_branch_remote?(acceptance_branch_name)
        git.checkout(acceptance_branch_name)
      else
        git.create_branch(acceptance_branch_name, "master".freeze)
        git.checkout(acceptance_branch_name)
      end

      delete_old_acceptance_branches if @options.cleanup
    end

    private

    def delete_old_acceptance_branches
      old_acceptance_branches.each { |branch_name|
        @git.branches.delete(branch_name) if @git.branches.exist?(branch_name)
      }
    end

    def old_acceptance_branches
      @git.local_branch_names_include?(/-GS-acceptance/) - [acceptance_branch_name]
    end

    def acceptance_branch_name
      @acceptance_branch_name ||= monday_date.strftime("%Y-%m-%d-RS-acceptance")
    end

    def monday_date
      return today if today.monday?

      today.prev_day(today.cwday - 1)
    end
  end
end
