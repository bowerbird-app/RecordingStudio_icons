# frozen_string_literal: true

require "test_helper"
require "action_controller"
require "recording_studio"
require File.join(
  Gem.loaded_specs.fetch("recording_studio").full_gem_path,
  "app/helpers/recording_studio/layout_helper"
)

require File.expand_path("../app/controllers/recording_studio_icons/application_controller", __dir__)
require File.expand_path("../app/controllers/recording_studio_icons/home_controller", __dir__)

class EngineLayoutTest < Minitest::Test
  def setup
    @original_gem_layout = RecordingStudioIcons.configuration.layout
    @original_core_layout = RecordingStudio.configuration.layout
  end

  def teardown
    RecordingStudioIcons.configuration.layout = @original_gem_layout
    RecordingStudio.configuration.layout = @original_core_layout
  end

  def test_engine_controllers_do_not_hard_code_a_layout
    engine_root = RecordingStudioIcons::Engine.root
    source = File.read(engine_root.join("app/controllers/recording_studio_icons/application_controller.rb"))

    refute_match(/layout\s+["']application["']/, source)
    assert_includes source, "recording_studio_layout"
    assert_empty RecordingStudio::Layout.hardcoded_layout_paths(engine_root)
  end

  def test_engine_home_uses_core_default_layout_when_settings_are_nil
    RecordingStudioIcons.configuration.layout = nil
    RecordingStudio.configuration.layout = nil

    assert_equal RecordingStudio::DEFAULT_LAYOUT, home_controller.recording_studio_resolved_layout
  end

  def test_engine_home_uses_gem_layout_before_core_layout
    RecordingStudio.configuration.layout = "host_shell"
    RecordingStudioIcons.configuration.layout = "icons_only"

    assert_equal "icons_only", home_controller.recording_studio_resolved_layout
  end

  def test_engine_home_follows_core_layout_when_gem_layout_is_nil
    RecordingStudioIcons.configuration.layout = nil
    RecordingStudio.configuration.layout = "host_shell"

    assert_equal "host_shell", home_controller.recording_studio_resolved_layout
  end

  def test_engine_home_skips_layout_when_gem_layout_is_false
    RecordingStudio.configuration.layout = "host_shell"
    RecordingStudioIcons.configuration.layout = false

    assert_equal false, home_controller.recording_studio_resolved_layout
  end

  private

  def home_controller
    RecordingStudioIcons::HomeController.new
  end
end
