module PicoClaw
  class BinaryManager
    BINARY_NAME = "picoclaw"

    def self.binary_path
      ENV.fetch("PICOCLAW_BINARY_PATH") { Rails.root.join("bin", BINARY_NAME).to_s }
    end

    def self.platform
      os = RbConfig::CONFIG["host_os"]
      cpu = RbConfig::CONFIG["host_cpu"]

      os_part = case os
      when /linux/i then "linux"
      when /darwin/i then "darwin"
      else "unknown"
      end

      arch_part = case cpu
      when /x86_64|amd64/i then "amd64"
      when /aarch64|arm64/i then "arm64"
      else "unknown"
      end

      "#{os_part}-#{arch_part}"
    end

    def self.exists?
      File.executable?(binary_path)
    end

    def self.version
      return nil unless exists?
      `#{binary_path} --version 2>/dev/null`.strip
    rescue StandardError
      nil
    end

    def self.healthy?
      exists? && version.present?
    end

    def self.status
      {
        path: binary_path,
        exists: exists?,
        version: version,
        platform: platform,
        healthy: healthy?,
      }
    end
  end
end
