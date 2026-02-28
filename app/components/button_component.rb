# frozen_string_literal: true

class ButtonComponent < ApplicationComponent
  VARIANTS = {
    primary:   "inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500",
    secondary: "inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50",
    danger:    "inline-flex items-center rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500",
    success:   "inline-flex items-center rounded-md bg-green-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-green-500",
    warning:   "inline-flex items-center rounded-md bg-yellow-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-yellow-500",
    dark:      "inline-flex items-center rounded-md bg-gray-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-gray-500"
  }.freeze

  def initialize(label:, path: nil, variant: :primary, method: nil, data: {})
    @label = label
    @path = path
    @variant = variant.to_sym
    @method = method
    @data = data
  end

  def css_classes
    VARIANTS.fetch(@variant, VARIANTS[:primary])
  end

  def button_to?
    @method.present?
  end
end
