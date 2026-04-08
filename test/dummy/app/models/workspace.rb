class Workspace < ApplicationRecord
	has_many :folders, dependent: :destroy
	has_many :pages, dependent: :destroy
end
