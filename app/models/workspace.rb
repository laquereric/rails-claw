class Workspace < ApplicationRecord
  has_many :agents, dependent: :destroy
  has_many :conversations, through: :agents

  validates :name, presence: true, uniqueness: true

  scope :running, -> { where(status: "running") }
  scope :stopped, -> { where(status: "stopped") }
  scope :errored, -> { where(status: "error") }

  def running?
    status == "running"
  end

  def stopped?
    status == "stopped"
  end

  def workspace_path
    path.presence || Rails.root.join("storage", "workspaces", id.to_s).to_s
  end
end
