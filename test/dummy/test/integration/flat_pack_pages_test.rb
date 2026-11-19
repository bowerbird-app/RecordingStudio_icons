# frozen_string_literal: true

require "test_helper"

class FlatPackPagesTest < ActionDispatch::IntegrationTest
  test "sign in page renders a card without the removed style argument" do
    get new_user_session_path

    assert_response :success
    assert_select "h2", text: "Sign In"
  end

  test "signed-in home renders sidebar icons as svg" do
    User.create!(email: "icons@example.com", password: "Password", password_confirmation: "Password")

    post user_session_path, params: {
      user: { email: "icons@example.com", password: "Password" }
    }
    follow_redirect!

    assert_response :success
    assert_select "h1", text: "RecordingStudioIcons demo"
    assert_select "svg", minimum: 1
    assert_select "[data-flat-pack--icon-name-value]", count: 0

    {
      basic_use_guide_path => "Use icon",
      set_icon_guide_path => "Set icon",
      configuration_reference_guide_path => "Configuration reference"
    }.each do |path, heading|
      get path

      assert_response :success
      assert_select "h1", text: heading
      assert_select "svg", minimum: 1
      assert_select "[data-flat-pack--icon-name-value]", count: 0
    end
  end
end
