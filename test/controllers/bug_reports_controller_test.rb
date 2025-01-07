require "test_helper"

class BugReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bug_report = bug_reports(:one)
  end

  test "should get index" do
    get bug_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_bug_report_url
    assert_response :success
  end

  test "should create bug_report" do
    assert_difference("BugReport.count") do
      post bug_reports_url, params: { bug_report: {  } }
    end

    assert_redirected_to bug_report_url(BugReport.last)
  end

  test "should show bug_report" do
    get bug_report_url(@bug_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_bug_report_url(@bug_report)
    assert_response :success
  end

  test "should update bug_report" do
    patch bug_report_url(@bug_report), params: { bug_report: {  } }
    assert_redirected_to bug_report_url(@bug_report)
  end

  test "should destroy bug_report" do
    assert_difference("BugReport.count", -1) do
      delete bug_report_url(@bug_report)
    end

    assert_redirected_to bug_reports_url
  end
end
