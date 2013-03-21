require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase
  setup do
    @resource = resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource" do
    assert_difference('Resource.count') do
      post :create, resource: { comment: @resource.comment, label: @resource.label, max_value: @resource.max_value, min_value: @resource.min_value, resource_type: @resource.resource_type, service_system_id: @resource.service_system_id, sid: @resource.sid, unit_of_measurement: @resource.unit_of_measurement, value: @resource.value }
    end

    assert_redirected_to resource_path(assigns(:resource))
  end

  test "should show resource" do
    get :show, id: @resource
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @resource
    assert_response :success
  end

  test "should update resource" do
    put :update, id: @resource, resource: { comment: @resource.comment, label: @resource.label, max_value: @resource.max_value, min_value: @resource.min_value, resource_type: @resource.resource_type, service_system_id: @resource.service_system_id, sid: @resource.sid, unit_of_measurement: @resource.unit_of_measurement, value: @resource.value }
    assert_redirected_to resource_path(assigns(:resource))
  end

  test "should destroy resource" do
    assert_difference('Resource.count', -1) do
      delete :destroy, id: @resource
    end

    assert_redirected_to resources_path
  end
end
