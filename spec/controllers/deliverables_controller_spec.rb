require 'spec_helper'
require 'controllers/permission_behavior'

describe DeliverablesController do

    before do
      @admin_andy = Factory(:admin_andy)
      @faculty_frank = Factory(:faculty_frank)
      @faculty_fagan = Factory(:faculty_fagan)
      @student_sam = Factory(:student_sam)
      @student_sally = Factory(:student_sally)
    end

    describe "GET index for course" do
      before(:each) do
        @course = mock_model(Course, :faculty => [@faculty_frank], :course_id => 42)
        @deliverable = stub_model(Deliverable, :course_id => @course.id)
        Deliverable.stub(:find_all_by_course_id).and_return([@deliverable, @deliverable])
        Course.stub(:find).and_return(@course)
      end

      context "as the faculty owner of the course" do

        before do
          login(@faculty_frank)
        end

        it 'assigns @deliverables' do
          get :index_for_course, :course_id => @course.id
          assigns(:deliverables).should == [@deliverable, @deliverable]
        end
      end

      context "as an admin" do

        before do
          login(@admin_andy)
        end

        it 'assigns @deliverables' do
          get :index_for_course, :course_id => @course.id
          assigns(:deliverables).should == [@deliverable, @deliverable]
        end
      end

      context "as any other user" do
        before do
          login(@faculty_fagan)
          get :index_for_course, :course_id => @course.id
        end

        it_should_behave_like "permission denied"
      end
    end


    describe "GET my_deliverables" do
      before(:each) do
        @course = mock_model(Course, :faculty => [@faculty_frank], :course_id => 42)
        @deliverable = stub_model(Deliverable, :course_id => @course.id, :owner_id => @student_sam.id)
        Deliverable.stub(:find_current_by_person).and_return([@deliverable, @deliverable])
        Deliverable.stub(:find_past_by_person).and_return([@deliverable, @deliverable])
        Course.stub(:find).and_return(@course)
      end

      context "as the owner of the deliverable" do
        before do
          login(@student_sam)
        end

        it 'assigns deliverables' do
          get :my_deliverables, :id => @student_sam.id
          assigns(:current_deliverables).should == [@deliverable, @deliverable]
          assigns(:past_deliverables).should == [@deliverable, @deliverable]
        end
      end

      context "as an faculty" do

        before do
          login(@faculty_frank)
          get :my_deliverables, :id => @student_sam.id

        end

        it 'assigns @deliverables' do
          assigns(:current_deliverables).should == [@deliverable, @deliverable]
          assigns(:past_deliverables).should == [@deliverable, @deliverable]
        end



      end
      context "as a faculty not related to the course"do
        before do
          login (@faculty_fagan)
          get :my_deliverables, :id => @student_sam.id

        end
        it_should_behave_like "permission denied for person deliverable"

      end
      context "as any other student" do
        before do
          login(@student_sally)
          get :my_deliverables, :id => @student_sam.id
        end

        it_should_behave_like "permission denied for person deliverable"
      end
    end


    describe "GET show" do
      before(:each) do
        @course = mock_model(Course, :faculty => [@faculty_frank], :course_id => 42)
        @deliverable = stub_model(Deliverable, :course_id => @course.id, :owner_id => @student_sam.id, :is_team_deliverable => true)
        @team = stub_model(Team)
        Deliverable.stub(:find).and_return(@deliverable)
        @deliverable.stub(:team).and_return(@team)
        Course.stub(:find).and_return(@course)
      end

      context "for a team deliverable" do

        it 'the owner can see it' do
          login(@student_sam)
          @team.stub(:is_person_on_team?).and_return(true)
          get :show, :id => @deliverable.id
          assigns(:deliverable).should == @deliverable
        end

        it "someone else on the team can see it" do
          login(@student_sally)
          @team.stub(:is_person_on_team?).and_return(true)
          get :show, :id => @deliverable.id
          assigns(:deliverable).should == @deliverable
        end

        it "any faculty can see it" do
          login(@faculty_frank)
          @team.stub(:is_person_on_team?).and_return(false)
          get :show, :id => @deliverable.id
          assigns(:deliverable).should == @deliverable
        end

        context "no other student can see it" do
          before do
            @team.stub(:is_person_on_team?).and_return(false)
            login(@student_sally)
            get :show, :id => @deliverable.id
          end

          it_should_behave_like "permission denied for person deliverable"
        end
      end
    end

    describe "Get new" do
       before(:each) do
       @course = mock_model(Course, :faculty => [@faculty_frank], :course_id => 42)
        @deliverable = stub_model(Deliverable, :course_id => @course.id, :owner_id => @student_sam.id, :is_team_deliverable => true)
        @team = stub_model(Team)
        Deliverable.stub(:find).and_return(@deliverable)
        @deliverable.stub(:team).and_return(@team)
        Course.stub(:find).and_return(@course)
       end

      it "should get new " do
        login(@student_sam)
        @team.stub(:is_person_on_team?).and_return(false)

        get :new, :course_id => @course.id, :task_number => 3
        assigns(:deliverable).creator.should == @student_sam
        assigns(:deliverable).creator.get_registered_courses == @student_sam.get_registered_courses
        assigns(:deliverable).course_id.should == @course.id
      end
    end
    describe "GET edit" do



      it "the user must be allowed to edit" do
         @course = mock_model(Course, :faculty => [@faculty_frank], :course_id => 42)
        @deliverable = stub_model(Deliverable, :course_id => @course.id, :owner_id => @student_sam.id, :is_team_deliverable => true)
        @team = stub_model(Team)
        Deliverable.stub(:find).and_return(@deliverable)
        @deliverable.stub(:team).and_return(@team)
        Course.stub(:find).and_return(@course)
        login(@student_sam)

        get :edit, :id => @deliverable

        response.should redirect_to(root_path)
      end
    end

#
#    describe "PUT update" do
#
#      before(:each) do
#        @effort_1 = stub_model(SponsoredProjectEffort)
#        @effort_2 = stub_model(SponsoredProjectEffort)
#
#        @effort_1.stub(:valid).and_return(true)
#        @effort_2.stub(:valid).and_return(true)
#
#        @effort_1.stub(:unique_month_year_allocation_id?).and_return(true)
#        @effort_2.stub(:unique_month_year_allocation_id?).and_return(true)
#
#        SponsoredProjectEffort.should_receive(:find).with("0").and_return(@effort_1)
#        SponsoredProjectEffort.should_receive(:find).with("1").and_return(@effort_2)
#
#        subject.should_receive(:setup_edit).and_return(true)
#
#        SponsoredProjectEffort.stub(:emails_business_manager)
#      end
#
#
#      describe "with valid params" do
#
#        it "updates the actual allocations" do
#          @effort_1.should_receive(:actual_allocation=).with("25")
#          @effort_2.should_receive(:actual_allocation=).with("75")
#          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
#        end
#
#        it 'updates the confirmed value' do
#          @effort_1.should_receive(:confirmed=).with(true)
#          @effort_2.should_receive(:confirmed=).with(true)
#          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
#        end
#
##        it 'sets the flash' do
##          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
##          flash.now[:notice].should_not be_nil
##        end
#
#        it "re-renders the 'edit' template" do
#          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
#          response.should render_template("edit")
#        end
#
#        it "emails the business manager when actual != confirmed" do
#          SponsoredProjectEffort.should_receive(:emails_business_manager)
#          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
#        end
#      end
#
#      describe "with invalid params" do
#
#        it 'sets the flash to error' do
#          @effort_2.should_receive(:save).and_return(false)
#          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
#          assigns(:failed).should == true
#          #flash.now[:error].should == "Your allocations did not save."
#        end
#
#        it "re-renders the 'edit' template" do
#          @effort_2.should_receive(:save).and_return(false)
#          put :update, :id => "AndrewCarnegie", :effort_id_values => {"0" => "25", "1" => "75"}
#          response.should render_template("edit")
#        end
#      end
#    end





  #-------------------------
  # Tests by Team Deuce Ace
  #-------------------------


   describe "Get index" do
    # @student_sam = Factory(:student_sam)
     it "should get redirect " do
       login(@faculty_frank)
        get :index
        response.should redirect_to(my_deliverables_path(assigns[:current_user]))
     end
  end


  describe "GET my_deliverables" do
    it "should not let everyone see every other person's deliverables"     do
      login(@student_sally)
      get :my_deliverables, :id => @student_sam
      response.should redirect_to root_path
    end

  end

  describe "GET edit" do
    it "should "
  end

end