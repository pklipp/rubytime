require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase
  fixtures :projects

  def setup
    @project = Project.find :first
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Project,  @project
  end
  
  def test_active_text
    p=Project.new
    p.is_inactive = true
    assert "YES", p.active_text
    p.is_inactive = false
    assert "NO", p.active_text
  end
end
