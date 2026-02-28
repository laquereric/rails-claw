# frozen_string_literal: true

class PlatformBadgeComponent < ApplicationComponent
  def initialize(platform:)
    @platform = platform
  end
end
