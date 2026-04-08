# frozen_string_literal: true

module Dummy
  module DemoData
    module_function

    DEMO_EMAIL = "admin@admin.com"
    DEMO_PASSWORD = "Password"
    DEMO_WORKSPACE_NAME = "Studio Workspace"
    DEMO_FOLDER_NAME = "Mix Folder"
    DEMO_PAGE_TITLE = "Session Notes"

    def ensure!
      return unless bootstrap_ready?

      user = User.find_or_initialize_by(email: DEMO_EMAIL)
      if user.new_record? || user.encrypted_password.blank?
        user.password = DEMO_PASSWORD
        user.password_confirmation = DEMO_PASSWORD
      end
      user.save! if user.new_record? || user.changed?

      workspace = Workspace.find_or_create_by!(name: DEMO_WORKSPACE_NAME)
      root_recording = RecordingStudio::Recording.unscoped.find_or_create_by!(
        recordable: workspace,
        parent_recording_id: nil
      )

      folder = workspace.folders.find_or_initialize_by(name: DEMO_FOLDER_NAME)
      folder.save! if folder.new_record? || folder.changed?
      folder_recording = RecordingStudio::Recording.unscoped.find_or_create_by!(
        root_recording_id: root_recording.id,
        parent_recording_id: root_recording.id,
        recordable: folder
      )

      page = workspace.pages.find_or_initialize_by(title: DEMO_PAGE_TITLE)
      page.folder = folder
      page.save! if page.new_record? || page.changed?
      RecordingStudio::Recording.unscoped.find_or_create_by!(
        root_recording_id: root_recording.id,
        parent_recording_id: folder_recording.id,
        recordable: page
      )

      previous_actor = Current.actor
      Current.actor = user

      access = RecordingStudio::Access.find_or_create_by!(actor: user, role: :admin)
      RecordingStudio::Recording.unscoped.find_or_create_by!(
        root_recording_id: root_recording.id,
        parent_recording_id: root_recording.id,
        recordable: access
      )
    ensure
      Current.actor = previous_actor
    end

    def bootstrap_ready?
      User.table_exists? &&
        Workspace.table_exists? &&
        Folder.table_exists? &&
        Page.table_exists? &&
        RecordingStudio::Access.table_exists? &&
        RecordingStudio::Recording.table_exists?
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      false
    end
  end
end