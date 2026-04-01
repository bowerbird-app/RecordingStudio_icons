# frozen_string_literal: true

RecordingStudioIcons.configure do |config|
  config.default_library = :heroicons

  config.map_icon_token :document,
    library: :heroicons,
    name: "document-text",
    variant: :outline

  config.fallback_icon = {
    library: :heroicons,
    name: "rectangle-stack",
    variant: :outline
  }
end

# Example registrations:
# RecordingStudioIcons.register_default_icon_token Workspace, :document
# RecordingStudioIcons.register_override_icon Workspace, library: :custom, name: "workspace"
