class ConversationsController < ApplicationController
  before_action :set_workspace
  before_action :set_conversation, only: [:show]

  def index
    @conversations = Conversation.joins(:agent)
      .where(agents: { workspace_id: @workspace.id })
      .includes(:agent, :messages)
      .order(updated_at: :desc)
  end

  def show
    @messages = @conversation.messages.ordered
  end

  private

  def set_workspace
    @workspace = Workspace.find(params[:workspace_id])
  end

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
