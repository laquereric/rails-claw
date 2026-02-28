# frozen_string_literal: true

class PageHeaderComponent < ApplicationComponent
  renders_one :actions

  def initialize(title:, subtitle: nil)
    @title = title
    @subtitle = subtitle
  end
end
