class AgentsController < ApplicationController
  before_action :set_workspace
  before_action :set_agent, only: [:show, :edit, :update, :destroy]

  def index
    @agents = @workspace.agents.order(:name)
  end

  def show
    @conversations = @agent.conversations.order(updated_at: :desc)
  end

  def new
    @agent = @workspace.agents.build
  end

  def create
    @agent = @workspace.agents.build(agent_params)

    if @agent.save
      redirect_to workspace_agent_path(@workspace, @agent), notice: "Agent created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @agent.update(agent_params)
      redirect_to workspace_agent_path(@workspace, @agent), notice: "Agent updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @agent.destroy
    redirect_to workspace_agents_path(@workspace), notice: "Agent deleted."
  end

  private

  def set_workspace
    @workspace = Workspace.find(params[:workspace_id])
  end

  def set_agent
    @agent = @workspace.agents.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:name, :soul_md, :agents_md, :memory_md, :heartbeat_md)
  end
end
