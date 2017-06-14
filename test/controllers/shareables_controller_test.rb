require 'test_helper'

class ShareablesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get shareables_new_url
    assert_response :success
  end

  test "should get create" do
    get shareables_create_url
    assert_response :success
  end

  test "should get edit" do
    get shareables_edit_url
    assert_response :success
  end

  test "should get update" do
    get shareables_update_url
    assert_response :success
  end

  test "should get destroy" do
    get shareables_destroy_url
    assert_response :success
  end

end
