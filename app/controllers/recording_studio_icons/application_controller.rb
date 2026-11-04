# frozen_string_literal: true

module RecordingStudioIcons
  class ApplicationController < ActionController::Base
    include RecordingStudio::ControllerLayout

    protect_from_forgery with: :exception

    recording_studio_layout { RecordingStudioIcons.configuration.layout }
  end
end
