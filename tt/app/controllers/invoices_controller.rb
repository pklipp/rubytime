class InvoicesController < ApplicationController
  before_filter :authorize
  layout "main", :except => 'print'
  
  #Default action.
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  #Lists invoices.
  def list
    @invoice_pages, @invoices = paginate :invoices, :per_page => 10
  end

  #Shows invoice's details.
  def show
    @invoice = Invoice.find(params[:id])
  end

  #Renders form for creating an invoice.
  def new
    @invoice = Invoice.new
  end

  #Creates new invoice.
  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.user_id = @current_user.id
    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  #Renders form for editing an invoice.
  def edit
    @invoice = Invoice.find(params[:id])
  end

  #Updates invoice.
  def update
    @invoice = Invoice.find(params[:id])
    @invoice.issued_at = Time.now if params[:invoice][:is_issued]
    @invoice.user_id = @current_user.id
    if @invoice.update_attributes(params[:invoice])
      flash[:notice] = 'Invoice was successfully updated.'
      redirect_to :action => 'show', :id => @invoice
    else
      render :action => 'edit'
    end
  end

  #Makes invoice issued.
  def issue
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes({'is_issued' => 1, 'issued_at' => Time.now})
      flash[:notice] = 'Invoice has been issued.'
    else
      flash[:notice] = 'Invoice has not been issued.'
    end
    redirect_to :action => :index
  end
  
  def add_activities
    @activities = Activity.find(:all, :conditions => ["invoice_id IS NULL AND id IN (?)",params[:id]])
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
  
  def remove_activities
    puts params.inspect
    @activities = Activity.find(:all, :conditions => ["id IN (?)",params[:id]])
    @success = true
    @activities.each do |activity|
      @success = activity.update_attribute('invoice_id', nil)     
    end
    if @success
      flash[:notice] = 'Activities has been removed from invoice.'
    else
      flash[:notice] = 'Error with removing activities form invoice.'
    end
    redirect_to :action => 'show', :id => params[:invoice_id]
  end    
  
end
