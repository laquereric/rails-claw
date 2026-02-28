# frozen_string_literal: true

class WorkspaceCardComponent < ApplicationComponent
  def initialize(workspace:)
    @workspace = workspace
  end
end
