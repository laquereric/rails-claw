# frozen_string_literal: true

class CardComponent < ApplicationComponent
  def initialize(title: nil)
    @title = title
  end
end
