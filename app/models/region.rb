class Region < ApplicationRecord
    belongs_to :disco
    has_many :divisions
    has_many :subdivisions, through: :divisions
    has_many :meters, through: :subdivisions
end
