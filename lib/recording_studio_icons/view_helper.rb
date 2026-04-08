# frozen_string_literal: true

module RecordingStudioIcons
  module ViewHelper
    def render_recording_studio_icon(recordable_or_type, **)
      RecordingStudioIcons.render_icon(self, recordable_or_type, **)
    end
  end
end
