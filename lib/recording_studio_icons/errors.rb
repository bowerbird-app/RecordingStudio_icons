# frozen_string_literal: true

module RecordingStudioIcons
  class Error < StandardError; end
  class InvalidConfigurationError < Error; end
  class InvalidIconReferenceError < Error; end
  class MissingRendererError < Error; end
end
