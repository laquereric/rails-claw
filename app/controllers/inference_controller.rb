class InferenceController < ApplicationController
  # GET /inference — Chat playground UI
  def index
    @vv_provider = VvProvider::HealthCheck.status
    @models = @vv_provider[:models] if @vv_provider[:connected]
  end

  # POST /inference/chat — Send a chat message
  def chat
    unless VvProvider::HealthCheck.connected?
      render json: { error: "VV Provider not connected. Install the VV Chrome extension to enable inference." }, status: :service_unavailable
      return
    end

    messages = params[:messages] || [{ role: "user", content: params[:message] }]
    model = params[:model]

    begin
      if params[:stream] == "true"
        response.headers["Content-Type"] = "text/event-stream"
        response.headers["Cache-Control"] = "no-cache"

        LlamaStack::ProviderClient.chat_completion(
          model: model,
          messages: messages,
          stream: true,
        ) do |chunk|
          response.stream.write("data: #{chunk.to_json}\n\n")
        end
        response.stream.write("data: [DONE]\n\n")
        response.stream.close
      else
        result = LlamaStack::ProviderClient.chat_completion(
          model: model,
          messages: messages,
        )
        render json: result
      end
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end
end
