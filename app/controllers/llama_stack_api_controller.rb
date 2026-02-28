class LlamaStackApiController < ApplicationController
  skip_forgery_protection

  # GET /api/v1/health
  def health
    render json: { status: "ok" }
  end

  # GET /api/v1/models
  def models
    status = VvProvider::HealthCheck.status
    if status[:connected]
      render json: { object: "list", data: status[:models] }
    else
      render json: { object: "list", data: [], error: status[:error] }
    end
  end

  # GET /api/v1/models/:id
  def show_model
    status = VvProvider::HealthCheck.status
    unless status[:connected]
      render json: { error: "VV Provider not connected" }, status: :service_unavailable
      return
    end

    model = status[:models].find { |m| m["id"] == params[:id] }
    if model
      render json: model
    else
      render json: { error: "Model not found" }, status: :not_found
    end
  end

  # GET /api/v1/providers
  def providers
    status = VvProvider::HealthCheck.status
    render json: {
      object: "list",
      data: [{
        provider_id: "vv-local-provider",
        provider_type: "remote::vv-local-provider",
        config: { url: status[:url] },
        connected: status[:connected],
      }],
    }
  end

  # GET /api/v1/providers/:id
  def show_provider
    status = VvProvider::HealthCheck.status
    render json: {
      provider_id: "vv-local-provider",
      provider_type: "remote::vv-local-provider",
      config: { url: status[:url] },
      connected: status[:connected],
    }
  end

  # POST /api/v1/inference/chat-completion
  # POST /api/v1/chat/completions
  def chat_completion
    result = LlamaStack::ProviderClient.chat_completion(
      model: params[:model],
      messages: params[:messages],
      stream: false,
      temperature: params[:temperature],
      max_tokens: params[:max_tokens],
    )
    render json: result
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /api/v1/inference/completion
  def completion
    result = LlamaStack::ProviderClient.completion(
      model: params[:model],
      prompt: params[:prompt],
      stream: false,
    )
    render json: result
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  # POST /api/v1/inference/embeddings
  # POST /api/v1/embeddings
  def embeddings
    result = LlamaStack::ProviderClient.embeddings(
      model: params[:model],
      input: params[:input],
    )
    render json: result
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end
end
