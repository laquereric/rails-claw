Rails.application.routes.draw do
  # Dashboard
  root "dashboard#index"

  # Workspaces
  resources :workspaces do
    member do
      post :start
      post :stop
      post :restart
      get "file/:name", action: :file, as: :file, constraints: { name: /[^\/]+/ }
      patch "file/:name", action: :update_file, as: :update_file, constraints: { name: /[^\/]+/ }
    end

    resources :agents
    resources :conversations, only: [:index, :show]
  end

  # Inference playground
  get "inference", to: "inference#index"
  post "inference/chat", to: "inference#chat"

  # Deployments
  get "deployments", to: "deployments#index"

  # Llama Stack API routes (Phase 1: Core)
  scope "api" do
    get "v1/health", to: "llama_stack_api#health"
    get "v1/models", to: "llama_stack_api#models"
    get "v1/models/:id", to: "llama_stack_api#show_model"
    get "v1/providers", to: "llama_stack_api#providers"
    get "v1/providers/:id", to: "llama_stack_api#show_provider"
    post "v1/inference/chat-completion", to: "llama_stack_api#chat_completion"
    post "v1/inference/completion", to: "llama_stack_api#completion"
    post "v1/inference/embeddings", to: "llama_stack_api#embeddings"
    post "v1/chat/completions", to: "llama_stack_api#chat_completion"
    post "v1/embeddings", to: "llama_stack_api#embeddings"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
