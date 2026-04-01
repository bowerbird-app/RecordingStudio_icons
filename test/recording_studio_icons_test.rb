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
    initializer_path = File.expand_path("dummy/config/initializers/recording_studio_icons.rb", __dir__)
    initializer_source = File.read(initializer_path)

    assert_includes initializer_source, "RecordingStudioIcons.configure"
    assert_includes initializer_source, "register_override_icon"
    assert_includes initializer_source, "register_renderer(:custom"
  end
end
