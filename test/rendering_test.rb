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
    @original_registry = RecordingStudioIcons.instance_variable_get(:@registry)
    RecordingStudioIcons.instance_variable_set(
      :@registry,
      RecordingStudioIcons::Registry.new(
        configuration: RecordingStudioIcons::Configuration.new,
        renderer_registry: RecordingStudioIcons::RendererRegistry.new
      )
    )
  end

  def teardown
    RecordingStudioIcons.instance_variable_set(:@registry, @original_registry)
  end

  def test_rendering_dispatches_by_library
    RecordingStudioIcons.register_renderer(:custom, StubRenderer)
    RecordingStudioIcons.register_default_icon(RenderType, { library: :custom, name: "custom-icon" })

    result = RecordingStudioIcons.render_icon(Object.new, RenderType, class: "h-5 w-5")

    assert_equal "rendered", result
    assert_equal :custom, StubRenderer.last_icon.library
    assert_equal({ class: "h-5 w-5" }, StubRenderer.last_options)
  end

  def test_view_helper_delegates_rendering_with_current_view_context
    RecordingStudioIcons.register_default_icon(RenderType, :folder)

    view_context = Object.new.extend(RecordingStudioIcons::ViewHelper)
    result = view_context.render_recording_studio_icon(RenderType, class: "h-5 w-5")

    assert_includes result, "<svg"
    assert_includes result, "data-icon-name=\"folder\""
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

  def test_heroicons_renderer_returns_svg_markup_for_known_icons
    icon = RecordingStudioIcons::IconReference.new(library: :heroicons, name: "folder", variant: :outline)

    result = RecordingStudioIcons::Renderers::Heroicons.render(ActionController::Base.helpers, icon, class: "h-5 w-5")

    assert_includes result, "<svg"
    assert_includes result, "recording-studio-icons__svg"
    assert_includes result, "data-icon-name=\"folder\""
    assert_includes result, "<path"
  end

  def test_heroicons_renderer_allows_safe_svg_options
    icon = RecordingStudioIcons::IconReference.new(library: :heroicons, name: "folder", variant: :outline)

    result = RecordingStudioIcons::Renderers::Heroicons.render(
      ActionController::Base.helpers,
      icon,
      class: "h-5 w-5",
      width: 20,
      height: 20,
      stroke_width: 2,
      role: "img",
      aria: { hidden: true },
      data: { testid: "folder-icon" }
    )

    assert_includes result, 'width="20"'
    assert_includes result, 'height="20"'
    assert_includes result, 'stroke-width="2"'
    assert_includes result, 'role="img"'
    assert_includes result, 'aria-hidden="true"'
    assert_includes result, 'data-testid="folder-icon"'
  end

  def test_heroicons_renderer_filters_unsafe_svg_options
    icon = RecordingStudioIcons::IconReference.new(library: :heroicons, name: "folder", variant: :outline)

    result = RecordingStudioIcons::Renderers::Heroicons.render(
      ActionController::Base.helpers,
      icon,
      class: "h-5 w-5",
      onclick: "alert(1)",
      onload: "alert(1)",
      viewBox: "0 0 10 10"
    )

    refute_includes result, "onclick"
    refute_includes result, "onload"
    assert_includes result, 'viewBox="0 0 24 24"'
  end

  def test_heroicons_renderer_falls_back_to_action_controller_helpers
    icon = RecordingStudioIcons::IconReference.new(library: :heroicons, name: "document-text", variant: :outline)

    result = RecordingStudioIcons::Renderers::Heroicons.render(Object.new, icon)

    assert_includes result, "data-icon-library=\"heroicons\""
    assert_includes result, "document-text"
  end

  def test_heroicons_renderer_returns_nil_for_unknown_icons
    icon = RecordingStudioIcons::IconReference.new(library: :heroicons, name: "missing-icon", variant: :outline)

    assert_nil RecordingStudioIcons::Renderers::Heroicons.render(ActionController::Base.helpers, icon)
  end
end
