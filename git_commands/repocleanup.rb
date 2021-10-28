require_relative "git_repository"

module GitCommands
  class Repocleanup

    attr_accessor :git_repo

    def initialize(path)
      @path     = path
      @git_repo = GitRepository.new(@path)
    end

    def run
      master_branch  = git_repo.branches["master"]
      master_sha     = master_branch.target_id
# binding.pry
      git_repo.branches.each do |branch|
        next if branch.name == "master"

        git_repo.delete_remote_branch(
          branch.name
        ) if ready_to_delete?(master_sha, branch.target_id, branch.name)
      end
    end

    private

    def ready_to_delete?(master_sha, branch_sha, branch_name)
      git_repo.is_fully_merged?(master_sha, branch_sha) && agree(sprintf("Do you want to delete %s branch? ", branch_name))
    end

  end
end

