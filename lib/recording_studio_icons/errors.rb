# frozen_string_literal: true

module RecordingStudioIcons
  class Error < StandardError; end
  class InvalidIconReferenceError < Error; end
  class MissingTokenMappingError < Error; end
  class MissingRendererError < Error; end
end
