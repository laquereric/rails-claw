module PicoClaw
  class WorkspaceManager
    TEMPLATE_FILES = {
      "SOUL.md" => "# Soul\n\nDefine the agent's core identity and purpose here.\n",
      "AGENTS.md" => "# Agents\n\nConfigure agent behaviors and capabilities.\n",
      "MEMORY.md" => "# Memory\n\nPersistent memory for the agent.\n",
      "HEARTBEAT.md" => "# Heartbeat\n\nScheduled tasks and periodic actions.\n",
    }.freeze

    DIRECTORIES = %w[cron skills].freeze

    attr_reader :workspace

    def initialize(workspace)
      @workspace = workspace
    end

    def create_structure
      base = workspace.workspace_path
      FileUtils.mkdir_p(base)

      DIRECTORIES.each { |dir| FileUtils.mkdir_p(File.join(base, dir)) }

      TEMPLATE_FILES.each do |filename, content|
        path = File.join(base, filename)
        File.write(path, content) unless File.exist?(path)
      end

      init_git(base)
      workspace.update!(path: base) unless workspace.path == base

      base
    end

    def read_file(filename)
      path = File.join(workspace.workspace_path, filename)
      return nil unless File.exist?(path)
      File.read(path)
    end

    def write_file(filename, content)
      path = File.join(workspace.workspace_path, filename)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
      git_commit(filename, "Update #{filename}")
      path
    end

    def list_files
      base = workspace.workspace_path
      return [] unless Dir.exist?(base)

      Dir.glob("#{base}/**/*")
        .select { |f| File.file?(f) }
        .map { |f| f.sub("#{base}/", "") }
        .reject { |f| f.start_with?(".git/") }
        .sort
    end

    def destroy_structure
      FileUtils.rm_rf(workspace.workspace_path)
    end

    private

    def init_git(path)
      return if Dir.exist?(File.join(path, ".git"))
      system("git", "init", path, out: File::NULL, err: File::NULL)
      system("git", "-C", path, "add", ".", out: File::NULL, err: File::NULL)
      system("git", "-C", path, "commit", "-m", "Initial workspace", out: File::NULL, err: File::NULL)
    end

    def git_commit(filename, message)
      path = workspace.workspace_path
      system("git", "-C", path, "add", filename, out: File::NULL, err: File::NULL)
      system("git", "-C", path, "commit", "-m", message, out: File::NULL, err: File::NULL)
    end
  end
end
