# frozen_string_literal: true

require "test_helper"

class ConfigLoaderTest < Minitest::Test
  def setup
    @configuration = RecordingStudioIcons::Configuration.new
  end

  def test_load_merges_yaml_source
    config_paths = {
      "config/recording_studio_icons.yml" => Struct.new(:existent).new(["config/recording_studio_icons.yml"])
    }
    config = Struct.new(:paths).new(config_paths)
    app = Struct.new(:config) do
      def config_for(_name)
        {
          default_library: :heroicons,
          raise_on_missing_renderer: true,
          default_icons: {
            "Workspace" => { library: :heroicons, name: "folder", variant: :outline }
          }
        }
      end
    end.new(config)

    RecordingStudioIcons::ConfigLoader.load!(app, configuration: @configuration)

    assert_equal "folder", @configuration.default_icons["Workspace"].name
    assert_equal true, @configuration.raise_on_missing_renderer
  end

  def test_load_skips_yaml_when_config_path_is_not_exposed
    config = Struct.new(:paths).new({ "config/recording_studio_icons.yml" => Object.new })
    app = Struct.new(:config) do
      def config_for(_name)
        raise "config_for should not be called"
      end
    end.new(config)

    RecordingStudioIcons::ConfigLoader.load!(app, configuration: @configuration)

    assert_equal({}, @configuration.default_icons)
  end

  def test_load_handles_apps_without_config_interfaces
    app = Object.new

    RecordingStudioIcons::ConfigLoader.load!(app, configuration: @configuration)

    assert_equal :heroicons, @configuration.default_library
  end

  def test_load_reraises_non_missing_yaml_errors
    config_paths = {
      "config/recording_studio_icons.yml" => Struct.new(:existent).new(["config/recording_studio_icons.yml"])
    }
    app = Struct.new(:config) do
      def config_for(_name)
        raise "boom"
      end
    end.new(Struct.new(:paths).new(config_paths))

    error = assert_raises(RuntimeError) do
      RecordingStudioIcons::ConfigLoader.load!(app, configuration: @configuration)
    end

    assert_equal "boom", error.message
  end

  def test_normalize_source_returns_nil_for_nil_values
    assert_nil RecordingStudioIcons::ConfigLoader.send(:normalize_source, nil, source: "config/recording_studio_icons.yml")
  end

  def test_normalize_source_accepts_each_pair_values
    value = Class.new do
      def each_pair
        yield(:default_library, :custom)
      end
    end.new

    result = RecordingStudioIcons::ConfigLoader.send(:normalize_source, value, source: "config/recording_studio_icons.yml")

    assert_equal({ default_library: :custom }, result)
  end

  def test_normalize_source_rejects_non_hash_like_values
    assert_raises(RecordingStudioIcons::InvalidConfigurationError) do
      RecordingStudioIcons::ConfigLoader.send(:normalize_source, "invalid", source: "config/recording_studio_icons.yml")
    end
  end
end