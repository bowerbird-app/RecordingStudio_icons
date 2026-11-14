# frozen_string_literal: true

require "test_helper"

class RecordingStudioIconsTest < Minitest::Test
  def test_version_exists
    assert_equal "0.2.1", ::RecordingStudioIcons::VERSION
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

    recording_studio_config = File.read(File.expand_path("dummy/config/initializers/recording_studio.rb", __dir__))
    refute_includes recording_studio_config, "include_children"
    refute_includes recording_studio_config, "RecordingStudio::Access"

    %w[workspace folder page].each do |model|
      source = File.read(File.expand_path("dummy/app/models/#{model}.rb", __dir__))
      assert_includes source, "recording_studio_recordable"
    end
  end

  def test_gitignore_covers_root_and_dummy_coverage
    gitignore = File.read(File.expand_path("../.gitignore", __dir__))

    assert_includes gitignore, "coverage/"
  end

  def test_dummy_gemfile_pins_recording_studio_and_flat_pack_tags
    gemfile = File.read(File.expand_path("dummy/Gemfile", __dir__))

    assert_includes gemfile, 'github: "bowerbird-app/RecordingStudio", tag: "v6.10.0"'
    assert_includes gemfile, 'github: "bowerbird-app/flatpack", tag: "v0.1.366"'

    root_gemfile = File.read(File.expand_path("../Gemfile", __dir__))
    assert_includes root_gemfile, 'github: "bowerbird-app/RecordingStudio", tag: "v6.10.0"'
    assert_includes root_gemfile, 'github: "bowerbird-app/flatpack", tag: "v0.1.366"'
  end

  def test_dummy_readme_matches_heroicons_demo
    readme = File.read(File.expand_path("dummy/README.md", __dir__))

    assert_includes readme, ":heroicons"
    refute_includes readme, "dummy `:custom` renderer"
  end
end
