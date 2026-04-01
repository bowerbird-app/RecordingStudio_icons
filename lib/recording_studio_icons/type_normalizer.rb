# frozen_string_literal: true

module RecordingStudioIcons
  module TypeNormalizer
    module_function

    def call(recordable_or_type)
      case recordable_or_type
      when String
        recordable_or_type
      when Symbol
        recordable_or_type.to_s
      when Class, Module
        recordable_or_type.name || recordable_or_type.to_s
      else
        recordable_or_type.class.name || recordable_or_type.class.to_s
      end
    end
  end
end
