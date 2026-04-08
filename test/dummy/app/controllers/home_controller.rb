class HomeController < ApplicationController
  DemoRow = Struct.new(:label, :recordable, :details, :notes, :count, keyword_init: true) do
    def type_name
      details.type_name
    end

    def source
      details.source.to_s.humanize
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
    workspace = Workspace.includes(:folders, :pages).first || Workspace.new(name: "Studio Workspace")
    folder = workspace.folders.first || Folder.new(name: "Mix Folder", workspace: workspace)
    page = workspace.pages.first || Page.new(title: "Session Notes", workspace: workspace, folder: folder)

    @demo_rows = [
      demo_row("Workspace", workspace, "Root RecordingStudio model using a configured default icon."),
      demo_row("Folder", folder, "Real child model using a configured default icon."),
      demo_row("Page", page, "Real nested model using a configured default icon.")
    ]
  end

  def basic_use_guide
    @basic_use_example = <<~ERB
      <%= render_recording_studio_icon(Page, class: "h-5 w-5") %>
    ERB
  end

  def set_icon_guide
    @set_icon_examples = [
      {
        label: "Class example",
        language: "ruby",
        code: <<~RUBY
          # app/models/page.rb
          class Page < ApplicationRecord
            RecordingStudioIcons.register_default_icon self,
              :document_duplicate
          end
        RUBY
      }
    ]
  end

  def configuration_reference_guide
    @configuration_flags_example = <<~YAML
      development:
        default_library: heroicons
        default_variant: solid
    YAML

    @configuration_override_examples = [
      {
        label: "Minimal override",
        language: "yaml",
        code: <<~YAML
          development:
            default_library: heroicons
            default_variant: solid
            override_icons:
              Page: star
        YAML
      },
      {
        label: "Full override",
        language: "yaml",
        code: <<~YAML
          development:
            override_icons:
              Page:
                library: heroicons
                name: star
                variant: solid
        YAML
      }
    ]
  end

  private

  def demo_row(label, recordable, notes)
    DemoRow.new(
      label: label,
      recordable: recordable,
      details: RecordingStudioIcons.resolve_icon_details(recordable),
      notes: notes,
      count: recordable.class.count
    )
  end
end
