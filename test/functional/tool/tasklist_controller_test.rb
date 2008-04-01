require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/tasklist_controller'

# Re-raise errors caught by the controller.
class Tool::TasklistController; def rescue_action(e) raise e end; end

class Tool::TasklistControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :task_lists, :tasks, :user_participations

  def setup
    @controller = Tool::TasklistController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    login_as :quentin
    
    get :show, :page_id => pages(:tasklist1)
    assert_response :success
    assert_template 'tool/tasklist/show'
  end

  def test_sort
    login_as :quentin
    assert_equal Task::Task.find(1).position, 1
    assert_equal Task::Task.find(2).position, 2
    assert_equal Task::Task.find(3).position, 3

    xhr :post, :sort, :controller => "tool/tasklist", :page_id => pages(:tasklist1).id, :id => 0, :sort_list_21_pending => ["3","2","1"]

    assert_equal Task::Task.find(1).position, 3
    assert_equal Task::Task.find(2).position, 2
    assert_equal Task::Task.find(3).position, 1
  end

  def test_multi_list_sort
    login_as :quentin
    tasks = Task::Task.find(1,2,3,4,5,6).index_by {|t| t.id}
    assert_equal tasks[1].position, 1
    assert_equal tasks[2].position, 2
    assert_equal tasks[3].position, 3
    assert_equal tasks[4].position, 1
    assert_equal tasks[5].position, 2
    assert_equal tasks[6].position, 3
    assert_not_equal tasks[2].task_list_id, tasks[4].task_list_id

    xhr :post, :sort, :controller => "tool/tasklist", :page_id => pages(:tasklist1).id, :id => 0, :sort_list_21_pending => ["1","3"]
    @controller = Tool::TasklistController.new
    xhr :post, :sort, :controller => "tool/tasklist", :page_id => pages(:tasklist2).id, :id => 0, :sort_list_22_pending => ["4","5","2","6"]

    tasks = Task::Task.find(1,2,3,4,5,6).index_by {|t| t.id}
    assert_equal tasks[1].position, 1
    assert_equal tasks[2].position, 3
    assert_equal tasks[3].position, 2
    assert_equal tasks[4].position, 1
    assert_equal tasks[5].position, 2
    assert_equal tasks[6].position, 4
    assert_equal tasks[2].task_list_id, tasks[4].task_list_id
  end
  
  def test_create_task
    login_as :quentin
    assert_difference 'pages(:tasklist1).data.tasks.count' do
      xhr :post, :create_task, :controller => "tool/tasklist", :page_id => pages(:tasklist1).id, :task => {:name => "new task", :user_ids => ["5"], :description => "new task description"}
    end
  end
  
  # TODO: tests for mark_task_complete, mark_task_pending, destroy_task, update_task, edit_task

end
