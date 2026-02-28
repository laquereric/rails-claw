class WorkspacesController < ApplicationController
  before_action :set_workspace, only: [:show, :edit, :update, :destroy, :start, :stop, :restart, :file, :update_file]

  def index
    @workspaces = Workspace.all.order(:name)
  end

  def show
    @manager = PicoClaw::WorkspaceManager.new(@workspace)
    @files = @manager.list_files
    @current_file = params[:file] || "SOUL.md"
    @file_content = @manager.read_file(@current_file)
    @agents = @workspace.agents.order(:name)
  end

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspace.new(workspace_params)
    @workspace.path = Rails.root.join("storage", "workspaces", SecureRandom.hex(8)).to_s

    if @workspace.save
      PicoClaw::WorkspaceManager.new(@workspace).create_structure
      redirect_to @workspace, notice: "Workspace created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @workspace.update(workspace_params)
      redirect_to @workspace, notice: "Workspace updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    PicoClaw::WorkspaceManager.new(@workspace).destroy_structure
    @workspace.destroy
    redirect_to workspaces_path, notice: "Workspace deleted."
  end

  # PicoClaw process controls
  def start
    result = PicoClaw::ProcessManager.new(@workspace).start
    if result[:error]
      redirect_to @workspace, alert: result[:error]
    else
      redirect_to @workspace, notice: "Agent started (PID: #{result[:pid]})."
    end
  end

  def stop
    PicoClaw::ProcessManager.new(@workspace).stop
    redirect_to @workspace, notice: "Agent stopped."
  end

  def restart
    PicoClaw::ProcessManager.new(@workspace).restart
    redirect_to @workspace, notice: "Agent restarted."
  end

  # File editor actions
  def file
    manager = PicoClaw::WorkspaceManager.new(@workspace)
    @current_file = params[:name]
    @file_content = manager.read_file(@current_file) || ""

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to workspace_path(@workspace, file: @current_file) }
    end
  end

  def update_file
    manager = PicoClaw::WorkspaceManager.new(@workspace)
    manager.write_file(params[:name], params[:content])

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("file-status", partial: "workspaces/file_status", locals: { message: "Saved" }) }
      format.html { redirect_to workspace_path(@workspace, file: params[:name]), notice: "File saved." }
    end
  end

  private

  def set_workspace
    @workspace = Workspace.find(params[:id])
  end

  def workspace_params
    params.require(:workspace).permit(:name)
  end
end
