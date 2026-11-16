# frozen_string_literal: true

require "test_helper"

class EngineTest < Minitest::Test
  include IsolatedIconRegistry

  ConfigStub = Struct.new(:recording_studio_icons)

  def test_engine_keeps_config_merge_and_view_helper_initializers
    names = RecordingStudioIcons::Engine.initializers.map(&:name)

    assert_includes names, "recording_studio_icons.load_config"
    assert_includes names, "recording_studio_icons.view_helpers"
    refute_includes names, "recording_studio_icons.before_initialize"
    refute_includes names, "recording_studio_icons.after_initialize"
  end

  def test_load_config_merges_initializer_source
    app = Struct.new(:config).new(
      ConfigStub.new(
        {
          default_library: :custom,
          default_icons: { "Workspace" => { library: :heroicons, name: "folder", variant: :outline } }
        }
      )
    )

    find_initializer("recording_studio_icons.load_config").block.call(app)

    assert_equal :custom, RecordingStudioIcons.configuration.default_library
    assert_equal "folder", RecordingStudioIcons.configuration.default_icons["Workspace"].name
  end

  def test_load_config_is_noop_when_initializer_config_is_absent
    app = Struct.new(:config).new(Object.new)

    find_initializer("recording_studio_icons.load_config").block.call(app)

    assert_equal false, RecordingStudioIcons.configuration.raise_on_missing_renderer
  end

  private

  def find_initializer(name)
    RecordingStudioIcons::Engine.initializers.find { |initializer| initializer.name == name }
  end
end
