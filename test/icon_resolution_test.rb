# frozen_string_literal: true

require "test_helper"

class IconResolutionTest < Minitest::Test
  DocumentType = Class.new
  CommentType = Class.new
  AudioType = Class.new
  UnknownType = Class.new

  def setup
    @original_registry = RecordingStudioIcons.instance_variable_get(:@registry)
    RecordingStudioIcons.instance_variable_set(:@registry, RecordingStudioIcons::Registry.new)
  end

  def teardown
    RecordingStudioIcons.instance_variable_set(:@registry, @original_registry)
  end

  def test_type_normalization_for_class_string_and_instance
    RecordingStudioIcons.register_default_icon(DocumentType, { library: :custom, name: "document" })

    from_class = RecordingStudioIcons.resolve_icon(DocumentType)
    from_string = RecordingStudioIcons.resolve_icon(DocumentType.name)
    from_instance = RecordingStudioIcons.resolve_icon(DocumentType.new)

    assert_equal from_class, from_string
    assert_equal from_class, from_instance
  end

  def test_default_icon_registration
    RecordingStudioIcons.register_default_icon(DocumentType,
                                               { library: :heroicons, name: "document-text", variant: :outline })

    result = RecordingStudioIcons.resolve_icon_details(DocumentType)

    assert_equal :default_icon, result.source
    assert_equal :heroicons, result.icon.library
  end

  def test_default_icon_registration_for_another_type
    RecordingStudioIcons.register_default_icon(CommentType, { library: :custom, name: "comment" })

    result = RecordingStudioIcons.resolve_icon_details(CommentType)

    assert_equal :default_icon, result.source
    assert_equal "comment", result.icon.name
  end

  def test_override_icon_takes_precedence_over_default_icon
    RecordingStudioIcons.register_default_icon(CommentType, { library: :custom, name: "comment-default" })
    RecordingStudioIcons.register_override_icon(CommentType,
                                                { library: :heroicons, name: "comment-override", variant: :solid })

    result = RecordingStudioIcons.resolve_icon_details(CommentType)

    assert_equal :override_icon, result.source
    assert_equal "comment-override", result.icon.name
  end

  def test_override_icon_takes_precedence_over_default_icons
    RecordingStudioIcons.register_default_icon(AudioType,
                                               { library: :heroicons, name: "speaker-wave", variant: :outline })
    RecordingStudioIcons.register_override_icon(AudioType, { library: :custom, name: "audio-override" })

    result = RecordingStudioIcons.resolve_icon_details(AudioType)

    assert_equal :override_icon, result.source
    assert_equal "audio-override", result.icon.name
  end

  def test_fallback_icon_behavior
    RecordingStudioIcons.configuration.fallback_icon = { library: :custom, name: "fallback" }

    result = RecordingStudioIcons.resolve_icon_details(UnknownType)

    assert_equal :fallback, result.source
    assert_equal "fallback", result.icon.name
  end

  def test_returns_none_when_no_icon_or_fallback_is_registered
    result = RecordingStudioIcons.resolve_icon_details(DocumentType)

    assert_equal :none, result.source
    assert_nil result.icon
  end
end
