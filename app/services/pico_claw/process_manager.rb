module PicoClaw
  class ProcessManager
    attr_reader :workspace

    def initialize(workspace)
      @workspace = workspace
    end

    def start
      return { error: "Already running (PID: #{workspace.picoclaw_pid})" } if running?
      return { error: "PicoClaw binary not found" } unless BinaryManager.exists?

      pid = spawn(
        BinaryManager.binary_path,
        "--workspace", workspace.workspace_path,
        out: log_path,
        err: log_path
      )
      Process.detach(pid)

      workspace.update!(status: "running", picoclaw_pid: pid)
      Rails.logger.info "[PicoClaw] Started workspace #{workspace.name} (PID: #{pid})"

      { pid: pid, status: "running" }
    rescue StandardError => e
      workspace.update!(status: "error")
      Rails.logger.error "[PicoClaw] Failed to start workspace #{workspace.name}: #{e.message}"
      { error: e.message }
    end

    def stop
      return { status: "already stopped" } unless workspace.picoclaw_pid

      begin
        Process.kill("TERM", workspace.picoclaw_pid)
        Rails.logger.info "[PicoClaw] Stopped workspace #{workspace.name} (PID: #{workspace.picoclaw_pid})"
      rescue Errno::ESRCH
        Rails.logger.warn "[PicoClaw] Process #{workspace.picoclaw_pid} already dead"
      end

      workspace.update!(status: "stopped", picoclaw_pid: nil)
      { status: "stopped" }
    end

    def restart
      stop
      start
    end

    def running?
      return false unless workspace.picoclaw_pid
      Process.kill(0, workspace.picoclaw_pid)
      true
    rescue Errno::ESRCH, Errno::EPERM
      # Process is dead — clean up stale PID
      workspace.update!(status: "stopped", picoclaw_pid: nil) if workspace.status == "running"
      false
    end

    def status
      alive = running?
      {
        workspace_id: workspace.id,
        pid: workspace.picoclaw_pid,
        running: alive,
        status: alive ? "running" : "stopped",
      }
    end

    private

    def log_path
      File.join(workspace.workspace_path, "picoclaw.log")
    end
  end
end
