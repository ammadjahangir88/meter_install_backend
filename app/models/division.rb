class Division < ApplicationRecord
    belongs_to :disco
    has_many :subdivisions
    has_many :meters, through: :subdivisions
end
