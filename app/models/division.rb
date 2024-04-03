class Division < ApplicationRecord
    belongs_to :region
    has_many :subdivisions
    has_many :meters, through: :subdivisions
end
