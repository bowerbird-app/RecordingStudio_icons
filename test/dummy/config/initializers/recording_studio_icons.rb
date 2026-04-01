RecordingStudioIcons.register_renderer(:custom, CustomDemoIconRenderer)

RecordingStudioIcons.configure do |config|
  config.default_library = :heroicons
  config.map_icon_token :workspace,
    library: :heroicons,
    name: "folder",
    variant: :outline
  config.map_icon_token :document,
    library: :heroicons,
    name: "document-text",
    variant: :outline
  config.fallback_icon = {
    library: :custom,
    name: "fallback-recording"
  }
end

RecordingStudioIcons.register_override_icon Workspace,
  library: :custom,
  name: "workspace-host"
RecordingStudioIcons.register_override_icon_token DemoAudioClip, :document
