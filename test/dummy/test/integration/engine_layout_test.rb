# frozen_string_literal: true

require "test_helper"

class EngineLayoutTest < ActionDispatch::IntegrationTest
  test "engine home is mounted and uses the core default layout" do
    assert_equal "/recording_studio_icons/", recording_studio_icons.root_path
    assert_equal RecordingStudio::DEFAULT_LAYOUT,
                 RecordingStudioIcons::HomeController.new.recording_studio_resolved_layout
  end

  test "engine home renders core default layout and one heading" do
    get recording_studio_icons.root_path

    assert_response :success
    assert_select "[data-recording-studio-default-layout='true']"
    assert_select "title", text: "Icons"
    assert_select "h1", text: "Icons", count: 1
  end
end
