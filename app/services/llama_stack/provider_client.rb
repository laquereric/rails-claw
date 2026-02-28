require "json"
require "net/http"
require "uri"
require "securerandom"

module LlamaStack
  module ProviderClient
    def self.base_url
      VvProvider::HealthCheck.base_url
    end

    # Chat completion — always targets vv-local-provider.
    # When stream: true and a block is given, yields SSE chunks.
    def self.chat_completion(model:, messages:, stream: false, **params, &block)
      uri = URI("#{base_url}/v1/chat/completions")

      body = {
        model: model,
        messages: normalize_messages(messages),
        stream: stream,
      }
      body[:temperature] = params[:temperature] if params[:temperature]
      body[:max_tokens] = params[:max_tokens] if params[:max_tokens]
      body[:top_p] = params[:top_p] if params[:top_p]

      if stream && block
        stream_request(uri, body, &block)
      else
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        data = http_post_json(uri, body, timeout: params[:timeout] || 120)
        elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round

        ResponseFormatter.chat_completion(
          content: data.dig("choices", 0, "message", "content"),
          model: model,
          input_tokens: data.dig("usage", "prompt_tokens"),
          output_tokens: data.dig("usage", "completion_tokens"),
          latency_ms: elapsed_ms,
        )
      end
    end

    # Text completion — prompt string, not chat messages.
    def self.completion(model:, prompt:, stream: false, **params, &block)
      uri = URI("#{base_url}/v1/completions")

      body = {
        model: model,
        prompt: prompt,
        stream: stream,
      }
      body[:temperature] = params[:temperature] if params[:temperature]
      body[:max_tokens] = params[:max_tokens] if params[:max_tokens]

      if stream && block
        stream_request(uri, body, format: :completion, &block)
      else
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        data = http_post_json(uri, body, timeout: params[:timeout] || 120)
        elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round

        ResponseFormatter.text_completion(
          text: data.dig("choices", 0, "text"),
          model: model,
          input_tokens: data.dig("usage", "prompt_tokens"),
          output_tokens: data.dig("usage", "completion_tokens"),
          latency_ms: elapsed_ms,
        )
      end
    end

    # Embeddings — returns vector arrays.
    def self.embeddings(model:, input:, **params)
      uri = URI("#{base_url}/v1/embeddings")
      input = [input] if input.is_a?(String)

      body = { model: model, input: input }

      data = http_post_json(uri, body, timeout: params[:timeout] || 60)

      ResponseFormatter.embeddings(
        embeddings: (data["data"] || []).map { |d| d["embedding"] },
        model: model,
        input_count: input.size,
      )
    end

    # --- Streaming ---

    def self.stream_request(uri, body, format: :chat, &block)
      completion_id = "chatcmpl-#{SecureRandom.hex(12)}"
      http = build_http(uri, timeout: 300)
      request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      request.body = body.to_json

      http.request(request) do |response|
        unless response.is_a?(Net::HTTPSuccess)
          raise "VV Provider error: HTTP #{response.code}"
        end

        response.read_body do |chunk|
          chunk.each_line do |line|
            line = line.strip
            next unless line.start_with?("data: ")
            payload = line.sub("data: ", "")
            break if payload == "[DONE]"
            data = JSON.parse(payload) rescue next

            if format == :chat
              content = data.dig("choices", 0, "delta", "content")
              next unless content
              block.call(ResponseFormatter.chat_completion_chunk(
                content: content,
                completion_id: completion_id,
                model: body[:model],
              ))
            elsif format == :completion
              text = data.dig("choices", 0, "text")
              next unless text
              block.call(ResponseFormatter.text_completion_chunk(
                text: text,
                completion_id: completion_id,
                model: body[:model],
              ))
            end
          end
        end
      end
    end

    # --- Internals ---

    def self.normalize_messages(messages)
      messages.map do |m|
        m = m.transform_keys(&:to_s)
        { "role" => m["role"], "content" => m["content"] }
      end
    end

    def self.http_post_json(uri, body, timeout: 120)
      http = build_http(uri, timeout: timeout)
      request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      request.body = body.to_json

      resp = http.request(request)
      unless resp.is_a?(Net::HTTPSuccess)
        raise "VV Provider error: HTTP #{resp.code}: #{resp.body}"
      end
      JSON.parse(resp.body)
    rescue Errno::ECONNREFUSED
      raise "VV Provider not reachable at #{uri}. Is the VV Chrome extension running?"
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise "VV Provider timed out at #{uri}"
    end

    def self.build_http(uri, timeout: 120)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.read_timeout = timeout
      http.open_timeout = 10
      http
    end

    private_class_method :normalize_messages, :http_post_json, :build_http, :stream_request
  end
end
