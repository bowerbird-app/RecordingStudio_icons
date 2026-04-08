class Folder < ApplicationRecord
  belongs_to :workspace
  has_many :pages, dependent: :nullify
end