class Folder < ApplicationRecord
  recording_studio_recordable label: "Folder", root: false, allowed_parent_types: [ "Workspace" ]

  RecordingStudioIcons.register_default_icon self, :folder

  belongs_to :workspace
  has_many :pages, dependent: :nullify
end