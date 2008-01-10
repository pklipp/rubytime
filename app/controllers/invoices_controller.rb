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
    @invoices = Invoice.paginate(:per_page => 10, :page => params[:page] || 1)
#    respond_to do |format|
#      format.html # index.html.erb
#      format.js do
#        render :update do |page|
#          page.replace_html 'invoices_list', :partial => "list"
#        end
#      end
#    end
  end
  
  #Searches invoices
  def search
    conditions_string =" 1 ";
    if (!params[:search].nil?)
      date_from = params[:search]["date_from(1i)"].to_i.to_s \
              + "-" + params[:search]["date_from(2i)"].to_i.to_s \
              + "-" + params[:search]["date_from(3i)"].to_i.to_s
      date_to = params[:search]["date_to(1i)"].to_i.to_s \
              + "-" + params[:search]["date_to(2i)"].to_i.to_s \
              + "-" + params[:search]["date_to(3i)"].to_i.to_s
    
      if (!params[:search][:client_id].blank?)
        conditions_string+= " AND client_id='" + params[:search][:client_id]+ "' "
      end
      if (!params[:search]['date_from(1i)'].blank?)
        conditions_string+= " AND date >= '" + date_from + "'"
      end
      if (!params[:search]['date_to(1i)'].blank?)
        conditions_string+= " AND date <= '" + date_to + "'"
      end
      if(params[:search][:is_issued].to_i>0)
        if params[:search][:is_issued].to_i==1
          conditions_string+= " AND is_issued=0 "
        elsif params[:search][:is_issued].to_i==2
          conditions_string+= " AND is_issued=1 "
        end
      end
      if (!params[:search][:name].blank?)
        conditions_string+= " AND name LIKE '%" + params[:search][:name] + "%'"
      end
    end   
      @invoices = Invoice.find(:all, :conditions => conditions_string)
      render :partial => '/invoices/list'  
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
    @invoice.created_at = Time.now
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
    @invoice.issued_at = Time.now if !params[:invoice].nil? && params[:invoice][:is_issued]
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
  
  #Adds activities to invoice.
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
  
  #Removess activities from invoice.
  def remove_activities
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
  
  #Renders AJAX form for creating an invoice.
def add_new
    @invoice = Invoice.new
    @invoice.client_id =  params[:client_id]
    render :partial => '/invoices/add_new'
  end
  
  #Creates new invoice by AJAX.
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
