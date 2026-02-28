class Agent < ApplicationRecord
  belongs_to :workspace
  has_many :conversations, dependent: :destroy
  has_many :messages, through: :conversations

  validates :name, presence: true

  scope :running, -> { where(status: "running") }
  scope :stopped, -> { where(status: "stopped") }

  def running?
    status == "running"
  end
end
