# frozen_string_literal: true

require "test_helper"

class ValueObjectsTest < Minitest::Test
  def test_resolution_result_helpers_reflect_icon_presence_and_source
    fallback = RecordingStudioIcons::ResolutionResult.new(type_name: "Workspace", icon: nil, source: :none)
    resolved = RecordingStudioIcons::ResolutionResult.new(
      type_name: "Workspace",
      icon: RecordingStudioIcons::IconReference.new(library: :heroicons, name: "folder"),
      source: :fallback
    )

    refute fallback.resolved?
    refute fallback.fallback?
    assert resolved.resolved?
    assert resolved.fallback?
  end

  def test_type_normalizer_supports_symbols
    assert_equal "workspace", RecordingStudioIcons::TypeNormalizer.call(:workspace)
  end

  def test_icon_reference_rejects_blank_library_and_unsupported_values
    assert_raises(RecordingStudioIcons::InvalidIconReferenceError) do
      RecordingStudioIcons::IconReference.new(library: "", name: "folder")
    end

    assert_raises(RecordingStudioIcons::InvalidIconReferenceError) do
      RecordingStudioIcons::IconReference.normalize(Object.new, default_library: :heroicons)
    end
  end
end
