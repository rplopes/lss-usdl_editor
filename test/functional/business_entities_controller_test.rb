require 'test_helper'

class BusinessEntitiesControllerTest < ActionController::TestCase
  setup do
    @business_entity = business_entities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:business_entities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create business_entity" do
    assert_difference('BusinessEntity.count') do
      post :create, business_entity: { foaf_logo: @business_entity.foaf_logo, foaf_name: @business_entity.foaf_name, foaf_page: @business_entity.foaf_page, gr_description: @business_entity.gr_description, s_email: @business_entity.s_email, s_telephone: @business_entity.s_telephone, service_system_id: @business_entity.service_system_id, sid: @business_entity.sid }
    end

    assert_redirected_to business_entity_path(assigns(:business_entity))
  end

  test "should show business_entity" do
    get :show, id: @business_entity
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @business_entity
    assert_response :success
  end

  test "should update business_entity" do
    put :update, id: @business_entity, business_entity: { foaf_logo: @business_entity.foaf_logo, foaf_name: @business_entity.foaf_name, foaf_page: @business_entity.foaf_page, gr_description: @business_entity.gr_description, s_email: @business_entity.s_email, s_telephone: @business_entity.s_telephone, service_system_id: @business_entity.service_system_id, sid: @business_entity.sid }
    assert_redirected_to business_entity_path(assigns(:business_entity))
  end

  test "should destroy business_entity" do
    assert_difference('BusinessEntity.count', -1) do
      delete :destroy, id: @business_entity
    end

    assert_redirected_to business_entities_path
  end
end
