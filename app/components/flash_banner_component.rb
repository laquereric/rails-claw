# frozen_string_literal: true

class FlashBannerComponent < ApplicationComponent
  STYLES = {
    notice: { bg: "bg-green-50", text: "text-green-700" },
    alert:  { bg: "bg-red-50",   text: "text-red-700" }
  }.freeze

  def initialize(type:, message:)
    @type = type.to_sym
    @message = message
    @style = STYLES.fetch(@type, STYLES[:notice])
  end
end
