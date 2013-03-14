require 'test_helper'

class ServiceSystemsControllerTest < ActionController::TestCase
  setup do
    @service_system = service_systems(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_systems)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_system" do
    assert_difference('ServiceSystem.count') do
      post :create, service_system: { comment: @service_system.comment, label: @service_system.label, prefix: @service_system.prefix, uri: @service_system.uri, user_id: @service_system.user_id }
    end

    assert_redirected_to service_system_path(assigns(:service_system))
  end

  test "should show service_system" do
    get :show, id: @service_system
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service_system
    assert_response :success
  end

  test "should update service_system" do
    put :update, id: @service_system, service_system: { comment: @service_system.comment, label: @service_system.label, prefix: @service_system.prefix, uri: @service_system.uri, user_id: @service_system.user_id }
    assert_redirected_to service_system_path(assigns(:service_system))
  end

  test "should destroy service_system" do
    assert_difference('ServiceSystem.count', -1) do
      delete :destroy, id: @service_system
    end

    assert_redirected_to service_systems_path
  end
end
