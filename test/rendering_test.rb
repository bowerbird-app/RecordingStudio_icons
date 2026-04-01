# frozen_string_literal: true

require "test_helper"

class RenderingTest < Minitest::Test
  RenderType = Class.new

  class StubRenderer
    class << self
      attr_reader :last_icon, :last_options

      def render(_view_context, icon_reference, **options)
        @last_icon = icon_reference
        @last_options = options
        "rendered"
      end
    end
  end

  def setup
    @original_configuration = RecordingStudioIcons.instance_variable_get(:@configuration)
    @original_registry = RecordingStudioIcons.instance_variable_get(:@renderer_registry)
    RecordingStudioIcons.instance_variable_set(:@configuration, RecordingStudioIcons::Configuration.new)
    RecordingStudioIcons.instance_variable_set(:@renderer_registry, RecordingStudioIcons::RendererRegistry.new)
  end

  def teardown
    RecordingStudioIcons.instance_variable_set(:@configuration, @original_configuration)
    RecordingStudioIcons.instance_variable_set(:@renderer_registry, @original_registry)
  end

  def test_rendering_dispatches_by_library
    RecordingStudioIcons.register_renderer(:custom, StubRenderer)
    RecordingStudioIcons.register_default_icon(RenderType, { library: :custom, name: "custom-icon" })

    result = RecordingStudioIcons.render_icon(Object.new, RenderType, class: "h-5 w-5")

    assert_equal "rendered", result
    assert_equal :custom, StubRenderer.last_icon.library
    assert_equal({ class: "h-5 w-5" }, StubRenderer.last_options)
  end

  def test_missing_renderer_returns_nil_when_not_strict
    RecordingStudioIcons.register_default_icon(RenderType, { library: :missing, name: "unknown" })

    assert_nil RecordingStudioIcons.render_icon(Object.new, RenderType)
  end

  def test_missing_renderer_raises_when_strict
    RecordingStudioIcons.configuration.raise_on_missing_renderer = true
    RecordingStudioIcons.register_default_icon(RenderType, { library: :missing, name: "unknown" })

    assert_raises(RecordingStudioIcons::MissingRendererError) do
      RecordingStudioIcons.render_icon(Object.new, RenderType)
    end
  end
end
