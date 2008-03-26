require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < Test::Unit::TestCase
  fixtures :invoices

  # Replace this with your real tests.
  def test_migrations
    assert_equal Date.parse("2006-06-06"), Date.parse(invoices(:first).created_at.to_s)
    assert_equal "21:21", invoices(:first).created_at.to_time.strftime("%H:%M")    
  end
  
  def test_search
    assert_equal 4, Invoice.search(:date_from => "2005-05-01", :date_to => "2006-06-30").size
    assert_equal 1, Invoice.search(:client_id => 2).size
    assert_equal 2, Invoice.search(:is_issued => 2).size
    assert_equal 0, Invoice.search(:client_id => 2, :is_issued => 2).size
    assert_equal 3, Invoice.search(:client_id => 1, :name => 'invoice').size
  end

end
