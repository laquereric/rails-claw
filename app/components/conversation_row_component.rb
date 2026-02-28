# frozen_string_literal: true

class ConversationRowComponent < ApplicationComponent
  def initialize(conversation:, workspace: nil)
    @conversation = conversation
    @workspace = workspace
  end

  def linkable?
    @workspace.present?
  end
end
