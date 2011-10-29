require 'spec_helper'

describe EffortLog do

  context 'log_effort_week?' do
    it 'should respond to log_effort_week?' do
      EffortLog.should respond_to :log_effort_week?
    end

    it 'it is spring break' do
      EffortLog.log_effort_week?(2010, 9).should == false
      EffortLog.log_effort_week?(2010, 10).should == false
    end

    it 'it is not spring break' do
      (1..8).each do |week_number|
        EffortLog.log_effort_week?(2010, week_number).should == AcademicCalendar.week_during_semester?(2010, week_number)
      end
      (11..52).each do |week_number|
        EffortLog.log_effort_week?(2010, week_number).should == AcademicCalendar.week_during_semester?(2010, week_number)
      end
    end
  end

  context "is not valid" do
    [:person, :week_number, :year].each do |attr|
      it "without #{attr}" do
        subject.should_not be_valid
        subject.errors[attr].should_not be_empty
      end
    end    
  end

  #context "has_permission_to_edit" do
  #  before(:each) do
  #    @effort = Factory(:effort_log)
  #  end
  #
  #  #it "for effort log owner" do
  #  #  @effort.editable_by(@effort.person).should be_true
  #  #end
  #
  #  it "for admin who is not effort owner" do
  #    admin_andy = Factory(:admin_andy)
  #    @effort.person.should_not be_equal(admin_andy)
  #    @effort.editable_by(admin_andy).should be_true
  #  end
  #
  #  it "not for non admin and non effort log owner" do
  #    faculty_frank = Factory(:faculty_frank)
  #    @effort.person.should_not be_equal(faculty_frank)
  #    @effort.editable_by(faculty_frank).should be_false
  #  end
  #end

  context "has_permission_to_edit_period" do
    before(:each) do
      @effort = Factory(:effort_log)
    end

    context "within time period" do
      it "for admin who is not effort owner" do
        admin_andy = Factory(:admin_andy)
        @effort.person.should_not be_equal(admin_andy)
        @effort.editable_by(admin_andy).should be_true
      end

      it "for effort log owner" do

        @effort.editable_by(@effort.person).should be_true
      end

      it "not for non admin and non effort log owner" do
        faculty_frank = Factory(:faculty_frank)
        @effort.person.should_not be_equal(faculty_frank)
        @effort.editable_by(faculty_frank).should be_false
      end
    end

    context "outside of time period" do
      before(:each) do
        tenDaysAgo = Date.today-10
        @effort.year = tenDaysAgo.year
        @effort.week_number = tenDaysAgo.cweek
      end

      it "for admin who is not effort owner" do
        admin_andy = Factory(:admin_andy)
        @effort.person.should_not be_equal(admin_andy)
        @effort.editable_by(admin_andy).should be_true
      end

      it "for effort log owner" do
        @effort.editable_by(@effort.person).should be_false
      end

      it "not for non admin and non effort log owner" do
        faculty_frank = Factory(:faculty_frank)
        @effort.person.should_not be_equal(faculty_frank)
        @effort.editable_by(faculty_frank).should be_false
      end
    end
  end

  context "validate_effort_against_registered_courses where person" do
    before(:each) do
      @effort_log_line_item = Factory(:elli_line1)
      @effort = Factory(:effort_log, :effort_log_line_items => [@effort_log_line_item])
    end

    it "is signed up for the course" do
      person = @effort.person
      courses = [@effort_log_line_item.course]
      person.should_receive(:get_registered_courses).and_return(courses)

      error_message = @effort.validate_effort_against_registered_courses
      puts error_message
      error_message.should == "" #no error
    end

    it "is not signed up for the course" do
     person = @effort.person
      courses = []

      error_message = @effort.validate_effort_against_registered_courses
      error_message.should == @effort_log_line_item.course.name
    end
    
  end
   context "validate_effort_against_unregistered_courses where person is " do
     before(:each) do
      @effort_log_line_item = Factory(:elli_line1)
      @effort = Factory(:effort_log, :effort_log_line_items => [@effort_log_line_item])

     end

     it "is signed up for 1 course" do

       person = @effort.person
           courses = [@effort_log_line_item.course]
           person.should_receive(:get_registered_courses).and_return(courses)

       error_message = @effort.validate_effort_against_registered_courses
       error_message.should == "" #no error

       @effort.should_receive(:validate_effort_against_registered_courses).and_return(error_message)
       error_effort_logs_users = EffortLog.users_with_effort_against_unregistered_courses
       error_effort_logs_users[person].should_not == @effort_log_line_item.course.name

     end

   end
  context "determine total effort" do
        it "should compute for basic values" do
        @effort_log_line = Factory(:elli_line1,:day1 => 1,:day2 => 2,:day3 => 3, :day4 => 4,:day5 => 5, :day6 => 6,:day7 => 7)
        @effort_log_line2 = Factory(:elli_line1,:day1 => 1,:day2 => 2,:day3 => 3, :day4 => 4,:day5 => 5, :day6 => 6,:day7 => 7)

        @effort = Factory(:effort_log)
        @effort.effort_log_line_items << @effort_log_line
        @effort.effort_log_line_items << @effort_log_line2
        @effort.determine_total_effort
         @effort.sum.should == 28*2
          end

  end
    context "new_effort_log_line_item_attributes" do
      it "should create a new log line with right attributes" do
        @effort_log_line_attr = Factory.attributes_for(:elli_line1)
        @effort_log_line = Factory(:elli_line1)
        @effort = Factory(:effort_log)
        @effort.new_effort_log_line_item_attributes = [@effort_log_line_attr]
        @effort.effort_log_line_items[0].day2.should == 20.0
      end
    end
   context "existing_effort_log_line_item_attributes" do
     it "should update existing attributes hopefully" do
        @effort_log_line_attr = Factory.attributes_for(:elli_line1,:day1 => 1000)
        @effort_log_line = Factory(:elli_line1)
        @effort = Factory(:effort_log)
        @effort.effort_log_line_items << @effort_log_line
        @effort_hash = Hash[@effort_log_line.id.to_s,@effort_log_line_attr]
        @effort.existing_effort_log_line_item_attributes = @effort_hash
        @effort.effort_log_line_items[0].day1.should == 1000
     end
     it "should will get rid of line items if not in the hash" do
        @effort_log_line_attr = Factory.attributes_for(:elli_line1,:day1 => 1000)
        @effort_log_line = Factory(:elli_line1)
        @effort_log_line2 = Factory(:elli_line2)

        @effort = Factory(:effort_log)
        @effort.effort_log_line_items << @effort_log_line
        @effort.effort_log_line_items << @effort_log_line2

        @effort_hash = Hash[@effort_log_line.id.to_s,@effort_log_line_attr]
        @effort.existing_effort_log_line_item_attributes = @effort_hash
        @effort.effort_log_line_items[1].should_not be_nil
     end
   end
   context "save_effort_log_line_items" do
     it "should save all the log line items correctly" do
      @effort_log_line_item = Factory.build(:elli_line1, :day1 => "HEY")
      @effort = Factory(:effort_log)
      @effort.effort_log_line_items << @effort_log_line_item
     @effort.save_effort_log_line_items.should == false
    end
   end

  context "latest for person" do
    it "should find the latest effort log"do
      @effort_log_line_item = Factory(:elli_line1)
      @effort = Factory(:effort1, :effort_log_line_items => [@effort_log_line_item])

      person = @effort.person
      @effort1 = EffortLog.create(:person_id => person.id, :week_number => @effort.week_number,:year => @effort.year)
      @effort2 = EffortLog.create(:person_id => person.id, :week_number => @effort.week_number,:year => @effort.year)

      effort_log = EffortLog.latest_for_person(person.id, @effort1.week_number, @effort1.year)
      effort_log.id.should == @effort.id
    end

  end



end
