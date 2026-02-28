class Conversation < ApplicationRecord
  belongs_to :agent
  has_many :messages, dependent: :destroy

  validates :platform, presence: true

  delegate :workspace, to: :agent

  def message_count
    messages.count
  end

  def last_message_at
    messages.maximum(:created_at)
  end
end
