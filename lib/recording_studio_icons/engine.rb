# frozen_string_literal: true

module RecordingStudioIcons
  class Engine < ::Rails::Engine
    isolate_namespace RecordingStudioIcons

    initializer "recording_studio_icons.before_initialize", before: "recording_studio_icons.load_config" do |_app|
      RecordingStudioIcons::Hooks.run(:before_initialize, self)
    end

    initializer "recording_studio_icons.load_config" do |app|
      if app.respond_to?(:config_for)
        begin
          yaml = begin
            app.config_for(:recording_studio_icons)
          rescue StandardError
            nil
          end
          RecordingStudioIcons.configuration.merge!(yaml) if yaml.respond_to?(:each)
        rescue StandardError
          nil
        end
      end

      if app.config.respond_to?(:x) && app.config.x.respond_to?(:recording_studio_icons)
        xcfg = app.config.x.recording_studio_icons
        if xcfg.respond_to?(:to_h)
          RecordingStudioIcons.configuration.merge!(xcfg.to_h)
        else
          begin
            hash = {}
            xcfg.each_pair { |key, value| hash[key] = value } if xcfg.respond_to?(:each_pair)
            RecordingStudioIcons.configuration.merge!(hash) if hash.any?
          rescue StandardError
            nil
          end
        end
      end

      RecordingStudioIcons::Hooks.run(:on_configuration, RecordingStudioIcons.configuration)
    end

    initializer "recording_studio_icons.after_initialize", after: "recording_studio_icons.load_config" do |_app|
      RecordingStudioIcons::Hooks.run(:after_initialize, self)
    end
  end
end
