# frozen_string_literal: true

require "test_helper"

class CoreFacadeTest < Minitest::Test
  FacadeType = Class.new

  def setup
    @original_registry = RecordingStudioIcons.instance_variable_get(:@registry)
    RecordingStudioIcons.instance_variable_set(:@registry, RecordingStudioIcons::Registry.new)
  end

  def teardown
    RecordingStudioIcons.instance_variable_set(:@registry, @original_registry)
  end

  def test_configure_with_block_updates_configuration
    result = RecordingStudioIcons.configure do |config|
      config.default_library = :custom
    end

    assert_equal :custom, result.default_library
    assert_equal :custom, RecordingStudioIcons.configuration.default_library
  end

  def test_reset_configuration_restores_default_library
    RecordingStudioIcons.configure { |config| config.default_library = :custom }

    RecordingStudioIcons.reset_configuration!

    assert_equal :heroicons, RecordingStudioIcons.configuration.default_library
  end

  def test_reset_renderers_restores_builtin_heroicons_renderer
    RecordingStudioIcons.register_renderer(:custom, Class.new)

    RecordingStudioIcons.reset_renderers!

    assert_nil RecordingStudioIcons.renderer_registry.fetch(:custom)
    assert_equal RecordingStudioIcons::Renderers::Heroicons, RecordingStudioIcons.renderer_registry.fetch(:heroicons)
  end

  def test_icon_for_type_delegates_to_resolution
    RecordingStudioIcons.register_default_icon(FacadeType, :folder)

    icon = RecordingStudioIcons.icon_for_type(FacadeType)

    assert_equal "folder", icon.name
  end

  def test_normalize_helpers_delegate_to_registry
    icon = RecordingStudioIcons.normalize_icon_reference(:document_text)
    type = RecordingStudioIcons.normalize_type(:workspace)

    assert_equal :heroicons, icon.library
    assert_equal "document-text", icon.name
    assert_equal "workspace", type
  end
end