# frozen_string_literal: true

module RecordingStudioIcons
  class Engine < ::Rails::Engine
    isolate_namespace RecordingStudioIcons

    initializer "recording_studio_icons.view_helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper RecordingStudioIcons::ViewHelper
      end
    end

    initializer "recording_studio_icons.before_initialize", before: "recording_studio_icons.load_config" do |_app|
      RecordingStudioIcons::Hooks.run(:before_initialize, self)
    end

    initializer "recording_studio_icons.load_config", after: :load_config_initializers do |app|
      host_config = app.config.respond_to?(:recording_studio_icons) ? app.config.recording_studio_icons : nil
      RecordingStudioIcons.configuration.merge!(host_config)

      RecordingStudioIcons::Hooks.run(:on_configuration, RecordingStudioIcons.configuration)
    end

    initializer "recording_studio_icons.after_initialize", after: "recording_studio_icons.load_config" do |_app|
      RecordingStudioIcons::Hooks.run(:after_initialize, self)
    end
  end
end
