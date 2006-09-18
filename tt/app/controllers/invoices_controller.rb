class InvoicesController < ApplicationController
  before_filter :authorize
  layout "main"
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @invoice_pages, @invoices = paginate :invoices, :per_page => 10
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.issued_at = Time.now if params[:invoice][:is_issued]
    if @invoice.update_attributes(params[:invoice])
      flash[:notice] = 'Invoice was successfully updated.'
      redirect_to :action => 'show', :id => @invoice
    else
      render :action => 'edit'
    end
  end

  def issue
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes({'is_issued' => 1, 'issued_at' => Time.now})
      flash[:notice] = 'Invoice has been issued.'
    else
      flash[:notice] = 'Invoice has not been issued.'
    end
    redirect_to :action => :index
  end  
  
end
