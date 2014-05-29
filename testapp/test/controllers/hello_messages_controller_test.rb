require 'test_helper'

class HelloMessagesControllerTest < ActionController::TestCase
  setup do
    @hello_message = hello_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hello_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create hello_message" do
    assert_difference('HelloMessage.count') do
      post :create, hello_message: { message: @hello_message.message, times_shown: @hello_message.times_shown }
    end

    assert_redirected_to hello_message_path(assigns(:hello_message))
  end

  test "should show hello_message" do
    get :show, id: @hello_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @hello_message
    assert_response :success
  end

  test "should update hello_message" do
    patch :update, id: @hello_message, hello_message: { message: @hello_message.message, times_shown: @hello_message.times_shown }
    assert_redirected_to hello_message_path(assigns(:hello_message))
  end

  test "should destroy hello_message" do
    assert_difference('HelloMessage.count', -1) do
      delete :destroy, id: @hello_message
    end

    assert_redirected_to hello_messages_path
  end
end
