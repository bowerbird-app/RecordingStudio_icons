# frozen_string_literal: true

require "test_helper"

class RegistryTest < Minitest::Test
  RegistryType = Class.new

  class StubRenderer
    class << self
      attr_reader :last_icon

      def render(_view_context, icon_reference, **_options)
        @last_icon = icon_reference
        "registry-rendered"
      end
    end
  end

  def setup
    @registry = RecordingStudioIcons::Registry.new(
      configuration: RecordingStudioIcons::Configuration.new,
      renderer_registry: RecordingStudioIcons::RendererRegistry.new
    )
  end

  def test_initialize_registers_builtin_heroicons_renderer
    assert_equal RecordingStudioIcons::Renderers::Heroicons, @registry.renderer_registry.fetch(:heroicons)
  end

  def test_configure_returns_configuration_and_yields_it
    yielded = nil

    result = @registry.configure do |config|
      yielded = config
      config.default_library = :custom
    end

    assert_same result, yielded
    assert_equal :custom, result.default_library
  end

  def test_reset_configuration_restores_defaults
    @registry.configuration.default_library = :custom
    @registry.register_default_icon(RegistryType, :folder)

    @registry.reset_configuration!

    assert_equal :heroicons, @registry.configuration.default_library
    assert_equal({}, @registry.configuration.default_icons)
  end

  def test_reset_renderers_clears_custom_renderers_and_keeps_builtin_renderer
    @registry.register_renderer(:custom, StubRenderer)

    @registry.reset_renderers!

    assert_nil @registry.renderer_registry.fetch(:custom)
    assert_equal RecordingStudioIcons::Renderers::Heroicons, @registry.renderer_registry.fetch(:heroicons)
  end

  def test_render_icon_dispatches_with_registered_renderer
    @registry.register_renderer(:custom, StubRenderer)
    @registry.register_default_icon(RegistryType, { library: :custom, name: "custom-icon" })

    result = @registry.render_icon(Object.new, RegistryType)

    assert_equal "registry-rendered", result
    assert_equal :custom, StubRenderer.last_icon.library
  end

  def test_render_icon_returns_nil_when_no_icon_is_registered
    assert_nil @registry.render_icon(Object.new, RegistryType)
  end
end
