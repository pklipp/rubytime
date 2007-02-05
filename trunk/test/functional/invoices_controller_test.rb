require File.dirname(__FILE__) + '/../test_helper'
require 'invoices_controller'

# Re-raise errors caught by the controller.
class InvoicesController; def rescue_action(e) raise e end; end

class InvoicesControllerTest < Test::Unit::TestCase
  fixtures :invoices
  fixtures :clients

  def setup
    @controller = InvoicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session = { :user_id =>  1 }
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:invoices)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:invoice)
    assert assigns(:invoice).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:invoice)
  end

  def test_create
    num_invoices = Invoice.count

    post :create, :invoice => {:name => "Inv 3", :client_id => 1, :user_id => 1, :created_at => Time.now  }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_invoices + 1, Invoice.count
  end

  def test_edit
    get :edit, :id => 1
    
    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:invoice)
    assert assigns(:invoice).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

# no destroy action
#  def test_destroy
#    assert_not_nil Invoice.find(1)
#
#    post :destroy, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_raise(ActiveRecord::RecordNotFound) {
#      Invoice.find(1)
#    }
#  end
end
