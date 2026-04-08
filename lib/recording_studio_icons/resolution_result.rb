# frozen_string_literal: true

module RecordingStudioIcons
  class ResolutionResult
    attr_reader :type_name, :icon, :source

    def initialize(type_name:, icon:, source:)
      @type_name = type_name
      @icon = icon
      @source = source
    end

    def fallback?
      source == :fallback
    end

    def resolved?
      !icon.nil?
    end
  end
end
