# frozen_string_literal: true

require "test_helper"

class RecordingStudioIconsTest < Minitest::Test
  def test_version_exists
    refute_nil ::RecordingStudioIcons::VERSION
  end

  def test_engine_exists
    assert_kind_of Class, ::RecordingStudioIcons::Engine
  end

  def test_dummy_app_uses_flatpack_sidebar_layout
    layout_path = File.expand_path("dummy/app/views/layouts/flat_pack_sidebar.html.erb", __dir__)
    assert File.exist?(layout_path)

    application_controller_path = File.expand_path("dummy/app/controllers/application_controller.rb", __dir__)
    controller_source = File.read(application_controller_path)
    assert_includes controller_source, "flat_pack_sidebar"
  end

  def test_dummy_app_configures_icon_registry_demo
    config_path = File.expand_path("dummy/config/initializers/recording_studio_icons.rb", __dir__)
    config_source = File.read(config_path)
    application_controller_path = File.expand_path("dummy/app/controllers/application_controller.rb", __dir__)
    controller_source = File.read(application_controller_path)

    assert_includes config_source, "Rails.application.config.recording_studio_icons"
    assert_includes config_source, '"Workspace" =>'
    assert_includes config_source, '"RecordingStudio::Access" =>'
    refute_includes controller_source, "reset_configuration!"
    refute_includes controller_source, "reset_renderers!"
  end
end
