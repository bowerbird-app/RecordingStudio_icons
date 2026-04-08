# frozen_string_literal: true

Rails.application.config.recording_studio_icons = {
  default_library: :heroicons,
  override_icons: {
    "Workspace" => {
      name: "document-text",
      variant: :outline
    }
  },
  fallback_icon: {
    name: "rectangle-stack",
    variant: :outline
  }
}
