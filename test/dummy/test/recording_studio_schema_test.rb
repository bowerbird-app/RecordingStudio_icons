# frozen_string_literal: true

require "test_helper"

class RecordingStudioSchemaTest < ActiveSupport::TestCase
  test "events require root_recording_id for core 6.9 timelines" do
    column = RecordingStudio::Event.columns_hash.fetch("root_recording_id")

    assert_equal :uuid, column.type
    assert_equal false, column.null
    assert RecordingStudio::Event.connection.index_exists?(
      :recording_studio_events,
      %i[root_recording_id occurred_at created_at id],
      name: "index_rs_events_on_root_and_timeline"
    )
  end
end
