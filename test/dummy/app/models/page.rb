class Page < ApplicationRecord
  RecordingStudioIcons.register_default_icon self, :document_duplicate

  belongs_to :workspace
  belongs_to :folder, optional: true
end