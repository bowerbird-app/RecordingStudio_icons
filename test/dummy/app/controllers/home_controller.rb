class HomeController < ApplicationController
  DemoRow = Struct.new(:label, :recordable, :details, :notes, :count, :icon_set_in, keyword_init: true) do
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
    access = RecordingStudio::Access.first || RecordingStudio::Access.new(role: :admin)

    @demo_rows = [
      demo_row("Workspace", workspace, "Root RecordingStudio model using a configured default icon.", "config/initializers/recording_studio_icons.rb"),
      demo_row("Folder", folder, "Real child model using a class-registered default icon.", "app/models/folder.rb"),
      demo_row("Page", page, "Real nested model using a class-registered default icon.", "app/models/page.rb"),
      demo_row("Access", access, "RecordingStudio access recordable using a configured default icon.", "config/initializers/recording_studio_icons.rb")
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
    @configuration_flags_example = <<~RUBY
      Rails.application.config.recording_studio_icons = {
        default_library: :heroicons,
        default_variant: :solid
      }
    RUBY

    @configuration_fallback_example = <<~RUBY
      Rails.application.config.recording_studio_icons = {
        default_library: :heroicons,
        fallback_icon: {
          name: "rectangle-stack",
          variant: :outline
        }
      }
    RUBY

    @configuration_unknown_library_example = <<~RUBY
      Rails.application.config.recording_studio_icons = {
        raise_on_missing_renderer: true
      }
    RUBY

    @configuration_override_examples = [
      {
        label: "Minimal override",
        language: "ruby",
        code: <<~RUBY
          Rails.application.config.recording_studio_icons = {
            default_library: :heroicons,
            default_variant: :solid,
            override_icons: {
              "Page" => :star
            }
          }
        RUBY
      },
      {
        label: "Full override",
        language: "ruby",
        code: <<~RUBY
          Rails.application.config.recording_studio_icons = {
            override_icons: {
              "Page" => {
                library: :heroicons,
                name: "star",
                variant: :solid
              }
            }
          }
        RUBY
      }
    ]
  end

  private

  def demo_row(label, recordable, notes, icon_set_in)
    DemoRow.new(
      label: label,
      recordable: recordable,
      details: RecordingStudioIcons.resolve_icon_details(recordable),
      notes: notes,
      count: recordable.class.count,
      icon_set_in: icon_set_in
    )
  end
end
