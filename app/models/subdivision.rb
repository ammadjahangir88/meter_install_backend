class Subdivision < ApplicationRecord
    belongs_to :division
    has_many :meters, dependent: :destroy
  end
  