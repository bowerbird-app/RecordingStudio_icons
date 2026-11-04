class Page < ApplicationRecord
  recording_studio_recordable label: "Page", root: false, allowed_parent_types: [ "Workspace", "Folder" ]

  RecordingStudioIcons.register_default_icon self, :document_duplicate

  belongs_to :workspace
  belongs_to :folder, optional: true
end