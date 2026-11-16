# frozen_string_literal: true

require "recording_studio"

module RecordingStudioIcons
  class Engine < ::Rails::Engine
    isolate_namespace RecordingStudioIcons

    initializer "recording_studio_icons.view_helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper RecordingStudioIcons::ViewHelper
      end
    end

    initializer "recording_studio_icons.load_config", after: :load_config_initializers do |app|
      host_config = app.config.respond_to?(:recording_studio_icons) ? app.config.recording_studio_icons : nil
      RecordingStudioIcons.configuration.merge!(host_config)
    end
  end
end
