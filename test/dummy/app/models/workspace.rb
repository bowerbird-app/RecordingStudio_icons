class Workspace < ApplicationRecord
  recording_studio_recordable label: "Workspace", root: true, allowed_parent_types: []

  has_many :folders, dependent: :destroy
  has_many :pages, dependent: :destroy
end
