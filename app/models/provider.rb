class Provider < ApplicationRecord
  has_many :models, dependent: :destroy, class_name: "AiModel"

  validates :name, presence: true, uniqueness: true
  validates :api_base, presence: true
end
