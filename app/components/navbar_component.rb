# frozen_string_literal: true

class NavbarComponent < ApplicationComponent
  NAV_ITEMS = [
    { label: "Dashboard", path: :root_path, match: ->(p) { p == "/" } },
    { label: "Workspaces", path: :workspaces_path, match: ->(p) { p.start_with?("/workspaces") } },
    { label: "Inference", path: :inference_path, match: ->(p) { p.start_with?("/inference") } },
    { label: "Deployments", path: :deployments_path, match: ->(p) { p.start_with?("/deployments") } }
  ].freeze

  def initialize(current_path:)
    @current_path = current_path
  end

  def active?(item)
    item[:match].call(@current_path)
  end

  def link_classes(item)
    base = "rounded-md px-3 py-2 text-sm font-medium"
    if active?(item)
      "#{base} bg-gray-900 text-white"
    else
      "#{base} text-gray-300 hover:bg-gray-700 hover:text-white"
    end
  end
end
