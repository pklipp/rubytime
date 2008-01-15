# ************************************************************************
# Ruby Time
# Copyright (c) 2006 Lunar Logic Polska sp. z o.o.
# 
# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ************************************************************************

class InvoicesController < ApplicationController
  before_filter :authorize, :load_invoice
  layout "main", :except => 'print'

  # Params filter provides reusable method prepare_search_dates
  require 'params_filter'
  include ParamsFilter

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

private
  def load_invoice
    @invoice = Invoice.find( params[:id] ) if params[:id]
    
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "Invoice not found"
    redirect_to :action => :index
  end

public

  #
  # Default action. Rendering list of invoices.
  #
  def index
    list
    render :action => 'list'
  end

  #
  # Lists all invoices using pagination
  #
  def list
    @invoices = Invoice.paginate(:per_page => 10, :page => params[:page] || 1)
  end
  
  #
  # Searches through invoices, presenting list of results
  #
  def search
    prepare_search_dates if params[:search]
    @invoices = Invoice.search( params[:search] )      

    render :partial => '/invoices/list'  
  end

  #
  # Shows invoice's details.
  # 
  def show
    assert_params_must_have :id    
  end

  #
  # Renders form for creating an invoice.
  #
  def new
    @invoice = Invoice.new
  end

  #
  # Creates new invoice.
  # This action is usually called from form created by +new+ action
  # 
  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.user_id = @current_user.id
    @invoice.created_at = Time.now
    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  #
  # Renders form for editing an invoice.
  #
  def edit
    assert_params_must_have :id
  end

  #
  # Updates invoice.
  # This action is usually called from form created by +edit+ action
  #
  def update
    assert_params_must_have :id
    
    @invoice.issued_at  = Time.now if !params[:invoice].nil? && params[:invoice][:is_issued]
    @invoice.user_id    = @current_user.id

    if @invoice.update_attributes(params[:invoice])
      flash[:notice] = 'Invoice was successfully updated.'
      redirect_to :action => 'show', :id => @invoice
    else
      render :action => 'edit'
    end
    
  end

  #
  # Makes invoice issued.
  #
  def issue
    assert_params_must_have :id
    
    unless @invoice.activities.empty?
      if @invoice.update_attributes({'is_issued' => 1, 'issued_at' => Time.now})
        flash[:notice] = 'Invoice has been issued.'
      else
        flash[:notice] = 'Eroros with issuing invoice.'
      end
    else
      flash[:notice] = 'No activities on this invoice! Cannot be issued!'
    end
    
    redirect_to :action => :show, :id => @invoice
  end
  
  #
  # Adds activities to invoice.
  #
  def add_activities
    @activities = Activity.find(:all, :conditions => ["invoice_id IS NULL AND id IN (?)",params[:activity_id]])
    @success = true
    @activities.each do |activity|
      @success = activity.update_attribute('invoice_id',params[:invoice_id])     
    end
    if @success
      flash[:notice] = 'Activities has been added to invoice.'
    else
      flash[:notice] = 'Error with adding activities to an invoice.'
    end
    redirect_to :action => 'show', :id => params[:invoice_id]
  end
  
  #
  # Removess activities from invoice.
  #
  def remove_activities
    assert_params_must_have :id
    
    @activities = Activity.find(:all, :conditions => ["id IN (?)",params[:activity_id]])
    @success = true
    @activities.each do |activity|
      @success = activity.update_attribute('invoice_id', nil)     
    end
    if @success
      flash[:notice] = 'Activities has been removed from invoice.'
    else
      flash[:notice] = 'Error with removing activities form invoice.'
    end

    redirect_to :action => 'show', :id => params[:id]
  end
  
  #
  # Renders AJAX form for creating an invoice.
  #
  def add_new
    @invoice = Invoice.new
    @invoice.client_id =  params[:client_id]
    render :partial => '/invoices/add_new'
  end
  
  #
  # Creates new invoice by AJAX.
  #
  def create_new
    @invoice = Invoice.new(params[:invoice])
    @invoice.user_id = @current_user.id
    @success = false
    if @invoice.save
      @success = true
    end
    @invoices = Invoice.find(:all, :conditions => ["client_id = ? AND is_issued=0", @invoice.client_id]) 
  end     
  
end
