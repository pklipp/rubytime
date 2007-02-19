require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < Test::Unit::TestCase
  fixtures :projects
  fixtures :users
  fixtures :roles

  def setup
    @controller = ProjectsController.new
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

    assert_not_nil assigns(:projects)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:project)
    assert assigns(:project).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:project)
  end

  def test_create
    num_projects = Project.count

    post :create, :project => { :name => "New project", :description => "desc", :client_id => 1}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_projects + 1, Project.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:project)
#    puts assigns(:project).inspect
    assert assigns(:project).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_confirm_destroy
    get :confirm_destroy, :id => 1

    assert_template 'confirm_destroy'
    assert assigns(:project)
  end

  def test_destroy
    num_projects = Project.count 
    project_id = 1
    
    project = Project.find(project_id)
    assert_not_nil project
    activities = Activity.find(:all, :conditions => ["project_id = ?",project_id])
    assert activities.size > 0

    post :destroy, :id => project_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    #destroy is not allowed yet
    assert_equal num_projects, Project.count

    #the name of the project must equal name_confirmed
    post :destroy, :id => project_id, :name_confirmation => project.name
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Project.find(project_id)
    }
    
    #all activities should be deleted as well
    activities = Activity.find(:all, :conditions => ["project_id = ?",project_id])
    assert_equal 0, activities.size
  end

  def test_destroy_all_and_add
    projects = Project.find(:all)
    projects.each do |p|
      p.destroy
    end
  
    assert_equal 0, Project.count

    get :list
    assert_tag :tag => "a", :attributes => { :href => "/projects/new" }
  end

end
