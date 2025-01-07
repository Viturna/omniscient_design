require "application_system_test_case"

class BugReportsTest < ApplicationSystemTestCase
  setup do
    @bug_report = bug_reports(:one)
  end

  test "visiting the index" do
    visit bug_reports_url
    assert_selector "h1", text: "Bug reports"
  end

  test "should create bug report" do
    visit bug_reports_url
    click_on "New bug report"

    click_on "Create Bug report"

    assert_text "Bug report was successfully created"
    click_on "Back"
  end

  test "should update Bug report" do
    visit bug_report_url(@bug_report)
    click_on "Edit this bug report", match: :first

    click_on "Update Bug report"

    assert_text "Bug report was successfully updated"
    click_on "Back"
  end

  test "should destroy Bug report" do
    visit bug_report_url(@bug_report)
    click_on "Destroy this bug report", match: :first

    assert_text "Bug report was successfully destroyed"
  end
end
