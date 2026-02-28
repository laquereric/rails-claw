require "net/http"
require "json"
require "uri"

module VvProvider
  module HealthCheck
    DEFAULT_URL = "http://localhost:8321"
    TIMEOUT = 2

    def self.base_url
      ENV.fetch("VV_PROVIDER_URL", DEFAULT_URL)
    end

    # Returns structured status hash:
    #   { connected: bool, url: str, models: [...], error: str? }
    def self.status
      url = base_url
      result = { connected: false, url: url, models: [], error: nil }

      begin
        health_uri = URI("#{url}/v1/health")
        http = Net::HTTP.new(health_uri.host, health_uri.port)
        http.use_ssl = (health_uri.scheme == "https")
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT

        response = http.get(health_uri.path)
        unless response.is_a?(Net::HTTPSuccess)
          result[:error] = "Health check returned HTTP #{response.code}"
          return result
        end

        result[:connected] = true
        result[:models] = fetch_models(url)
      rescue Errno::ECONNREFUSED
        result[:error] = "Connection refused at #{url}"
      rescue Net::OpenTimeout, Net::ReadTimeout
        result[:error] = "Connection timed out at #{url}"
      rescue StandardError => e
        result[:error] = e.message
      end

      result
    end

    def self.connected?
      status[:connected]
    end

    def self.fetch_models(url = base_url)
      uri = URI("#{url}/v1/models")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = TIMEOUT
      http.read_timeout = TIMEOUT

      response = http.get(uri.path)
      return [] unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      models = data["data"] || data["models"] || []
      models.map { |m| m.is_a?(Hash) ? m : { "id" => m.to_s } }
    rescue StandardError
      []
    end

    private_class_method :fetch_models
  end
end
