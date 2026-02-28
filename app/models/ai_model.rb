# Named AiModel to avoid conflict with ActiveRecord::Base "Model"
class AiModel < ApplicationRecord
  self.table_name = "models"

  belongs_to :provider

  validates :name, presence: true
  validates :api_model_id, presence: true

  scope :llm, -> { where(model_type: "llm") }
  scope :embedding, -> { where(model_type: "embedding") }
end
