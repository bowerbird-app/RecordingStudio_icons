# frozen_string_literal: true

module RecordingStudioIcons
  class Configuration
    module Layout
      attr_reader :layout

      def layout=(value)
        require "recording_studio/layout"
        @mutex.synchronize { @layout = RecordingStudio::Layout.accept(value) }
      end
    end
  end
end
