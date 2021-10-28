require "bundler"

module GitCommands
  class Bundler
    def initialize(path)
      @path = path
    end

    def bundle
      Dir.chdir(@path) do
        system("bundle")
      end
    end

    def update_engines(redmine_branch, engines)
      new_gemfile = gemfile.dup

      engines.each { |engine|
        current_engine_line   = new_gemfile.lines.grep(/#{engine}/).first
        current_engine_branch = current_engine_line.match(/branch:.*["'](.*)["']/).captures.first
        update_engine_line    = current_engine_line.sub(current_engine_branch, redmine_branch)
        new_gemfile           = new_gemfile.sub(current_engine_line, update_engine_line)
      }

      IO.write("Gemfile", new_gemfile)
    end

    def add_engines_to_bunder_config

    end

    def gemfile
      File.read(@path.join("Gemfile"))
    end
  end
end
