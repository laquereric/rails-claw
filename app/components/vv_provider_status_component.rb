# frozen_string_literal: true

class VvProviderStatusComponent < ApplicationComponent
  def initialize(provider:)
    @provider = provider
  end

  def connected?
    @provider[:connected]
  end

  def url
    @provider[:url]
  end

  def model_count
    @provider[:models]&.size || 0
  end

  def error
    @provider[:error]
  end

  def model_label
    "model#{model_count == 1 ? '' : 's'}"
  end
end
