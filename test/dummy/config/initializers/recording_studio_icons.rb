# frozen_string_literal: true

Rails.application.config.recording_studio_icons = {
  default_library: :heroicons,
  override_icons: {
    "Workspace" => {
      name: "rectangle-stack",
      variant: :outline
    },
    "RecordingStudio::Access" => {
      name: "chat-bubble-left-right",
      variant: :outline
    }
  }
}
