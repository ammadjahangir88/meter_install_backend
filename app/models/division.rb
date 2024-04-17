class Division < ApplicationRecord
    belongs_to :region
    has_many :subdivisions, dependent: :destroy
    has_many :meters, through: :subdivisions
  end
  