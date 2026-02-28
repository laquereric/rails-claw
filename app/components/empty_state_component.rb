# frozen_string_literal: true

class EmptyStateComponent < ApplicationComponent
  def initialize(message:, action_text: nil, action_path: nil)
    @message = message
    @action_text = action_text
    @action_path = action_path
  end

  def action?
    @action_text.present? && @action_path.present?
  end
end
