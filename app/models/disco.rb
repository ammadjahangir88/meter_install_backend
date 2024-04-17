class Disco < ApplicationRecord
    has_many :regions, dependent: :destroy
    has_many :divisions, through: :regions
    has_many :subdivisions, through: :divisions
    has_many :meters, through: :subdivisions
  end
  
