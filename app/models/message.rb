class Message < ApplicationRecord
  belongs_to :conversation

  validates :role, presence: true, inclusion: { in: %w[system user assistant] }
  validates :content, presence: true

  scope :ordered, -> { order(:created_at) }
  scope :by_role, ->(role) { where(role: role) }

  delegate :agent, to: :conversation
end
