# frozen_string_literal: true

class WorkspaceCardComponent < ApplicationComponent
  MAX_VISIBLE_AGENTS = 3

  STATUS_DOT_COLORS = {
    "running"   => "bg-green-400",
    "connected" => "bg-green-400",
    "error"     => "bg-red-400"
  }.freeze

  DEFAULT_DOT_COLOR = "bg-gray-400"

  def initialize(workspace:)
    @workspace = workspace
  end

  def agents
    @agents ||= @workspace.agents.order(:name)
  end

  def visible_agents
    agents.first(MAX_VISIBLE_AGENTS)
  end

  def remaining_count
    [agents.size - MAX_VISIBLE_AGENTS, 0].max
  end

  def dot_color(status)
    STATUS_DOT_COLORS.fetch(status.to_s, DEFAULT_DOT_COLOR)
  end
end
