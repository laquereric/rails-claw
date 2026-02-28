class DashboardController < ApplicationController
  def index
    @workspaces = Workspace.all
    @running_workspaces = Workspace.running
    @running_agents = Agent.running
    @recent_conversations = Conversation.includes(:agent).order(updated_at: :desc).limit(10)
    @vv_provider = VvProvider::HealthCheck.status
  end
end
