require 'spec_helper'

describe EffortLogsController do

  context "it should send midweekly reminder email to SE students" do
    it "who have not logged effort" do
      person_who_needs_reminder = Factory(:student_sam, :effort_log_warning_email => Date.today - 1.day)
      Person.stub(:where).and_return([person_who_needs_reminder])
      EffortLog.stub!(:latest_for_person).and_return(nil)

      (people_without_effort, people_with_effort) = subject.create_midweek_warning_email_for_se_students("random saying")
      people_without_effort[0].should == person_who_needs_reminder.human_name
      people_with_effort.size.should == 0
    end

    it "but skip those who have already been emailed" do
      person_whose_been_reminded = Factory(:faculty_frank, :effort_log_warning_email => Date.today)
      Person.stub(:where).and_return([person_whose_been_reminded])
      EffortLog.stub!(:latest_for_person).and_return(nil)

      (people_without_effort, people_with_effort) = subject.create_midweek_warning_email_for_se_students("random saying")
      people_without_effort.size.should == 0
      people_with_effort.size.should == 0
    end

    it "and not bother people who have logged effort" do
      person_who_has_logged_effort = Factory(:admin_andy, :effort_log_warning_email => Date.today - 7.days)
      Person.stub(:where).and_return([person_who_has_logged_effort])
      EffortLog.stub(:latest_for_person).and_return(mock_model(EffortLog, :sum => 1))

      (people_without_effort, people_with_effort) = subject.create_midweek_warning_email_for_se_students("random saying")
      people_without_effort.size.should == 0
      people_with_effort[0].should == person_who_has_logged_effort.human_name
    end

  end
     context "should have index" do
       before(:each) do
         @effort_log = Factory(:effort_log)
       @course = Factory(:course)
       @course2 = Factory(:fse)
         @effort_log2 = EffortLog.new(@effort_log.attributes)
         @effort_log2.week_number = @effort_log.week_number - 1
         @effort_log2.save
       login(@effort_log.person)
       end
       it "should have a successful response?" do
        get 'index'
         assigns(:effort_logs).length.should == 2
         assigns(:prior_week_number).should == @effort_log2.week_number
         assigns(:show_new_link).should == false
       end
       it "should allow grace period" do
         Date.stub(:commercial).and_return(Date.today)
         get 'index'
           assigns(:show_prior_week).should == true
       end



    end
   describe "should have show" do
     before(:each)do
       @effort_log = Factory(:effort_log)
       @admin_andy = Factory(:admin_andy)
       @course = Factory(:course)
       @course2 = Factory(:fse)
       login(@admin_andy)

     end
     it "should function basically" do
        get :show, :id => @effort_log
        assigns[:effort_log].should == @effort_log
        assigns[:courses][0].should == @course2
        assigns[:courses][1].should == @course

        assigns[:today_column].should_not be_nil
      end
   end
  describe "get new" do
    before(:each) do
       @admin_andy = Factory(:student_sam)
       @course = Factory(:course)
       @course2 = Factory(:fse)
       login(@admin_andy)
    end
    it "should create with basic stuff" do
      get :new
      assigns(:effort_log).year = "2011"
    end
  end
  describe "update" do
    before(:each)do
         @effort_log = Factory(:effort_log)
       @course = Factory(:course)
       @course2 = Factory(:fse)
    end
    it "should allow an update" do
      login(@effort_log.person)

      get :update, :id => @effort_log.id, :effort_log => {:year => "2009"}

       flash[:notice].should == "EffortLog was successfully updated."
      assigns(:effort_log).year.should == 2009
    end

    it "shouldn't allow a person not in that to edit'" do
      login(Factory(:student_sally))
      get :update, :id => @effort_log.id, :effort_log => @effort_log.attributes
      flash[:error].should == "You do not have permission to edit the effort log."
    end
  end

  #tests by Deuce Ace

  describe "edit" do

    it "should not allow students to create duplicate logs for the same course and type in one given week" do
      get 'edit', :id => 2
        @course1 = Factory(:mfse)
        type1   = "Readings"
        @course2 = Factory(:mfse)
        type2 = "Readings"
        if @course1.name == @course2.name
            type1.should_not == type2
        end
      end
    end
end