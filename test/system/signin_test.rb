require "application_system_test_case"

class SigninTest < ApplicationSystemTestCase
  test "user can signin and signout" do
    visit root_path

    assert_link "BeagleJobs"
    assert_button "Sign in"
    assert_css '[data-login-ready-value="true"]'

    click_link_or_button "Sign in"
    fill_in "Email address", with: users(:default, :email)
    click_link_or_button "Continue"
    fill_in "Password", with: users(:default, :password)
    click_link_or_button "Continue"

    assert_no_button "Sign in"
    assert_link "Bookmarks"

    assert_css 'div[data-controller="profile"] button'
    assert_css '[data-profile-ready-value="true"]'
    find('div[data-controller="profile"] button').click
    assert_button "Sign out"
    click_link_or_button "Sign out"
    assert_no_css 'div[data-controller="profile"] button'

    assert_no_link "Bookmarks"
    assert_button "Sign in"
  end
end
