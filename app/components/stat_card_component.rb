# frozen_string_literal: true

class StatCardComponent < ApplicationComponent
  COLORS = {
    gray:  "text-gray-900",
    green: "text-green-600",
    blue:  "text-blue-600",
    red:   "text-red-600"
  }.freeze

  def initialize(label:, value:, color: :gray)
    @label = label
    @value = value
    @value_color = COLORS.fetch(color.to_sym, COLORS[:gray])
  end
end
