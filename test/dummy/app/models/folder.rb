class Folder < ApplicationRecord
  RecordingStudioIcons.register_default_icon self, :folder

  belongs_to :workspace
  has_many :pages, dependent: :nullify
end