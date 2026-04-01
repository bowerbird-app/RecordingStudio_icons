class HomeController < ApplicationController
  DemoRow = Struct.new(:label, :recordable, :details, :notes, keyword_init: true) do
    def type_name
      details.type_name
    end

    def source
      details.source.to_s.humanize
    end

    def token
      details.token&.to_s || "—"
    end

    def library
      details.icon&.library&.to_s || "—"
    end

    def icon_name
      details.icon&.name || "—"
    end

    def variant
      details.icon&.variant&.to_s || "—"
    end
  end

  def index
    workspace = Workspace.first || Workspace.new(name: "Studio Workspace")

    @demo_rows = [
      demo_row("Workspace (host override icon)", workspace, "Real RecordingStudio recordable with a host-owned custom renderer override."),
      demo_row("DemoDocument (addon token default)", DemoDocument, "Addon-style semantic token mapped by the host app to Heroicons."),
      demo_row("DemoComment (addon direct icon)", DemoComment, "Concrete addon default icon reference for a type that needs a specific glyph."),
      demo_row("DemoAudioClip (host override token)", DemoAudioClip, "Host override token wins over the addon's default icon reference."),
      demo_row("DemoUnmappedRecordable (fallback)", DemoUnmappedRecordable, "Falls back to the configured icon when no type-specific registration exists.")
    ]
  end

  private

  def demo_row(label, recordable, notes)
    DemoRow.new(
      label: label,
      recordable: recordable,
      details: RecordingStudioIcons.resolve_icon_details(recordable),
      notes: notes
    )
  end
end
