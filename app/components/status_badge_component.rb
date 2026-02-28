# frozen_string_literal: true

class StatusBadgeComponent < ApplicationComponent
  COLORS = {
    "running"   => "bg-green-100 text-green-800",
    "connected" => "bg-green-100 text-green-800",
    "stopped"   => "bg-gray-100 text-gray-800",
    "error"     => "bg-red-100 text-red-800"
  }.freeze

  DEFAULT_COLOR = "bg-gray-100 text-gray-800"

  def initialize(status:)
    @status = status.to_s
  end

  def color_classes
    COLORS.fetch(@status, DEFAULT_COLOR)
  end
end
