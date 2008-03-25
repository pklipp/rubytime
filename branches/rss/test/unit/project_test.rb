require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  fixtures :projects, :clients

  def setup
    @project = Project.find :first
  end

  def test_active_text
    p=Project.new
    p.is_inactive = true
    assert "YES", p.active_text
    p.is_inactive = false
    assert "NO", p.active_text
  end
  
  def test_find_active
    ps = Project.find_active
    ps.each{|p| assert !p.is_inactive}
  end

  def test_find_active_for_client
    client = clients(:first_client)
    projects = Project.find_active_for_client(client)
    assert_equal projects.size, 5
    assert projects.all? {|p| !p.is_inactive?}
  end

  def test_client_id_is_protected
    @project.update_attributes({:name => "newname", :description => "newdesc", :client_id => 2})
    assert_equal "newname", @project.name
    assert_equal "newdesc", @project.description
    assert_equal 1, @project.client_id
  end

  def test_search
    assert_equal 6, Project.search({:client_id => 1}).size
    assert_equal 3, Project.search({:name => "cool"}).size
    assert_equal 2, Project.search({:name => "t2"}).size
    assert_equal 1, Project.search({:name => "t2", :client_id => 1}).size
    assert_kind_of Project, Project.search({:name => "t2", :client_id => 1})[0]
  end

  def test_create_report_by_role
    report = @project.create_report_by_role("2006-08-15", "2006-08-30")
    # there are 3 activities of user pm (admin) and 1 of user fox (dev)
    # expected result: [admin_act_1, admin_act_2, admin_act_3, <sum of admin's activity minutes>, fox_act, <sum of fox's activity minutes>]
    assert_equal 6, report.size
    assert_equal [Activity, Activity, Activity, Fixnum, Activity, Fixnum], report.collect {|elem| elem.class}
    assert_equal [1, 1, 1], report[0..2].collect(&:user_id)
    assert_equal 180, report[3]
    assert_equal 2, report[4].user_id
    assert_equal 60, report[5]
  end

end
