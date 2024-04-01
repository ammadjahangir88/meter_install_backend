class Disco < ApplicationRecord
    has_many :divisions
    has_many :subdivisions, through: :divisions
    has_many :meters, through: :subdivisions
end
