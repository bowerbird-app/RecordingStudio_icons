# frozen_string_literal: true

require "test_helper"

class IconDemoTest < ActiveSupport::TestCase
  test "dummy Access override still resolves from the type name" do
    details = RecordingStudioIcons.resolve_icon_details("RecordingStudio::Access")

    assert_equal "RecordingStudio::Access", details.type_name
    assert_equal "chat-bubble-left-right", details.icon.name
    assert_equal :outline, details.icon.variant
  end

  test "dummy models declare recording_studio_recordable for core 6.3.0" do
    RecordingStudio.validate_recordable_declarations!

    assert Workspace.respond_to?(:recording_studio_recordable)
    assert Folder.respond_to?(:recording_studio_recordable)
    assert Page.respond_to?(:recording_studio_recordable)
  end
end
