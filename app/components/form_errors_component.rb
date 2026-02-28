# frozen_string_literal: true

class FormErrorsComponent < ApplicationComponent
  def initialize(record:)
    @record = record
  end

  def render?
    @record.errors.any?
  end

  def messages
    @record.errors.full_messages
  end
end
