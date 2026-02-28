# frozen_string_literal: true

class MessageBubbleComponent < ApplicationComponent
  AVATAR_COLORS = {
    "user"      => "bg-blue-500",
    "assistant" => "bg-green-500",
    "system"    => "bg-gray-500"
  }.freeze

  def initialize(message:)
    @message = message
  end

  def avatar_color
    AVATAR_COLORS.fetch(@message.role, "bg-gray-500")
  end

  def avatar_letter
    @message.role[0].upcase
  end

  def user?
    @message.role == "user"
  end

  def bubble_bg
    user? ? "bg-blue-50" : "bg-gray-50"
  end

  def flex_direction
    user? ? "flex-row-reverse" : ""
  end

  def has_metadata?
    @message.tokens_used.present? || @message.latency_ms.present?
  end
end
