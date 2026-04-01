# frozen_string_literal: true

module RecordingStudioIcons
  class ResolutionResult
    attr_reader :type_name, :icon, :source, :token

    def initialize(type_name:, icon:, source:, token: nil)
      @type_name = type_name
      @icon = icon
      @source = source
      @token = token&.to_sym
    end

    def fallback?
      source == :fallback
    end

    def resolved?
      !icon.nil?
    end
  end
end
