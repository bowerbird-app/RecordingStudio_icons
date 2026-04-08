# frozen_string_literal: true

require "test_helper"

class IconReferenceTest < Minitest::Test
  def test_nil_normalization_returns_nil
    assert_nil RecordingStudioIcons::IconReference.normalize(nil)
  end

  def test_existing_icon_reference_is_returned_as_is
    icon = RecordingStudioIcons::IconReference.new(library: :heroicons, name: "document-text", variant: :outline)

    assert_same icon, RecordingStudioIcons::IconReference.normalize(icon)
  end

  def test_string_normalization_uses_default_library
    icon = RecordingStudioIcons::IconReference.normalize("document-text", default_library: :heroicons)

    assert_equal :heroicons, icon.library
    assert_equal "document-text", icon.name
  end

  def test_string_normalization_uses_default_variant
    icon = RecordingStudioIcons::IconReference.normalize(
      "document-text",
      default_library: :heroicons,
      default_variant: :solid
    )

    assert_equal :solid, icon.variant
  end

  def test_symbol_normalization_converts_underscores_to_hyphens
    icon = RecordingStudioIcons::IconReference.normalize(:document_text, default_library: :heroicons)

    assert_equal "document-text", icon.name
  end

  def test_hash_normalization_uses_default_variant_when_missing
    icon = RecordingStudioIcons::IconReference.normalize(
      { library: :custom, name: :app_document },
      default_variant: :filled
    )

    assert_equal :filled, icon.variant
  end

  def test_hash_normalization_preserves_variant_and_options
    icon = RecordingStudioIcons::IconReference.normalize(
      { library: :custom, name: :app_document, variant: :filled, options: { size: :lg } }
    )

    assert_equal :custom, icon.library
    assert_equal "app-document", icon.name
    assert_equal :filled, icon.variant
    assert_equal({ size: :lg }, icon.options)
  end

  def test_invalid_reference_without_name_raises
    assert_raises(RecordingStudioIcons::InvalidIconReferenceError) do
      RecordingStudioIcons::IconReference.normalize({ library: :heroicons })
    end
  end

  def test_invalid_reference_without_library_or_default_raises
    assert_raises(RecordingStudioIcons::InvalidIconReferenceError) do
      RecordingStudioIcons::IconReference.normalize("document-text")
    end
  end
end
