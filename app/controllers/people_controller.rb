class PeopleController < AuthController

  #only Requiring the right user to change own contents
  before_filter :correct_user, :only => [:edit, :update, :delete, :destroy]

  # GET /people
  # GET /people.xml
  def index
    @people = Person.all
    @title = "peoples"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    @title = "peoples"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new
    @title = "people"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    @title = "people"
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])
    @title = "people"
    @person.firstname = @person.firstname.upcase
    @person.lastname = @person.lastname.capitalize

    respond_to do |format|
      if @person.save

        begin
            #create association
            @asso = PartnerPerson.new()
            #@asso.person_id = @person.id
            @asso.person = @person
            if signed_in_and_master?
                @asso.partner_id = 1
            else
                @partner = Partner.all(:conditions => ["user_id = ?", current_user.id])
                @asso.partner_id = @partner[0].id
            end 
            @asso.save

        rescue Exception => e
            format.html { render :action => "new" }
            format.xml  { render :xml => @asso.errors, :status => :unprocessable_entity }
            return
        end 

        format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])
    @title = "people"

#    @person.firstname = @person.firstname.upcase
#    @person.lastname = @person.lastname.capitalize
    params[:person][:firstname] = params[:person][:firstname].upcase
    params[:person][:lastname] = params[:person][:lastname].upcase


    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    if !signed_in_and_master?
      flash[:notice] = "Sorry. Only technical manager can delete data. Please, contact Roberto SPURIO to do it."
      redirect_to altitude_types_path
    else

        @person = Person.find(params[:id])
        @person.destroy
        @title = "people"

        respond_to do |format|
          format.html { redirect_to(people_url) }
          format.xml  { head :ok }
        end
    end
  end

  private

    def correct_user
      reroute('1') unless signed_in?
      #retrieve partner by logged user
      @partner = Partner.all(:conditions => ["user_id = ?", current_user.id])
      if @partner.nil?
        reroute('2')
      else
        # PartnerPeople --> PartnerPerson
        @asso = PartnerPerson.all(:conditions => ["person_id = ? and partner_id = ?", params[:id], @partner[0].id])
        if @asso.nil? or @asso.count() <= 0
            reroute('3')
        end
#        #@user = User.find(@partner.user_id)
#        #uses the current_user? method,
#        #which (as with deny_access) we will define in the Sessions helper
#        reroute() unless current_user?(@user)
      end
    end

    def reroute(step)
      #flash[:notice] = "Only the partner who create the oligo sequence can modify it(" + step + ")."
      flash[:notice] = "Only the partner who create the oligo sequence can modify it."
      redirect_to(people_path)
    end
end

