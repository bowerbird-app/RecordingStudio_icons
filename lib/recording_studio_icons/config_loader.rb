# frozen_string_literal: true

module RecordingStudioIcons
  class ConfigLoader
    class << self
      def load!(app, configuration:)
        yaml_config = load_yaml_config(app)
        configuration.merge!(yaml_config) if yaml_config
      end

      private

      def load_yaml_config(app)
        return unless app.respond_to?(:config_for)
        return unless yaml_config_available?(app)

        normalize_source(app.config_for(:recording_studio_icons), source: "config/recording_studio_icons.yml")
      rescue RuntimeError => error
        raise unless missing_config_error?(error)
      end

      def yaml_config_available?(app)
        return true unless app.respond_to?(:config) && app.config.respond_to?(:paths)

        config_path = app.config.paths["config/recording_studio_icons.yml"]
        return false unless config_path.respond_to?(:existent)

        config_path.existent.any?
      end

      def normalize_source(value, source:)
        return if value.nil?
        return value.to_h if value.respond_to?(:to_h)

        if value.respond_to?(:each_pair)
          {}.tap do |memo|
            value.each_pair do |key, item|
              memo[key] = item
            end
          end
        else
          raise InvalidConfigurationError, "#{source} must be hash-like"
        end
      end

      def missing_config_error?(error)
        error.message.match?(/missing file|Could not load configuration/i)
      end
    end
  end
end