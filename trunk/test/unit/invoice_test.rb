require File.dirname(__FILE__) + '/../test_helper'

class InvoiceTest < Test::Unit::TestCase
  fixtures :invoices

  # Replace this with your real tests.
  def test_migrations
    assert_equal Date.parse("2006-06-06"), Date.parse(invoices(:first).created_at.to_s)
    assert_equal "21:21", invoices(:first).created_at.to_time.strftime("%H:%M")    
  end
  
end
