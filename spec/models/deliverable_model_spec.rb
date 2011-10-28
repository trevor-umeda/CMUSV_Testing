require 'spec_helper'

describe Deliverable do

  it 'can be created' do
    lambda {
      Factory(:deliverable)
    }.should change(Deliverable, :count).by(1)
  end

  context "is not valid" do

    [:course, :creator].each do |attr|
      it "without #{attr}" do
        subject.should_not be_valid
        subject.errors[attr].should_not be_empty
      end
    end
    context "Update Team" do
     it "should not update the team if the creators team isn't changed" do
      deliverable = Factory.build(:team_deliverable)
      team = Team.find_by_name("Team Triumphant")
      deliverable.stub(:update_team)
      deliverable.team_id.should == team.id
     end

    end
    context "when a duplicate deliverable for the same course, task and owner" do
      [:team_deliverable, :individual_deliverable].each do |symbol|
        it "for a team/individual deliverable" do
          original = Factory.build(symbol)
          original.stub(:update_team)
          original.save
          duplicate = Deliverable.new()
          duplicate.stub(:update_team)
          duplicate.creator_id = original.creator_id
          duplicate.course = original.course
          duplicate.task_number = original.task_number
          duplicate.is_team_deliverable = original.is_team_deliverable
          duplicate.team_id = original.team_id
          duplicate.should_not be_valid
        end
      end

      it "should be a duplicate but have diff creator id."  do
        original = Factory.build(:team_deliverable)
        original.stub(:update_team)
        sally = Person.find_by_last_name("Sally")
        sam = Person.find_by_last_name("Sam")
        original.creator = sam
        original.save
          duplicate = Deliverable.new()
          duplicate.stub(:update_team)
          duplicate.creator = sally
          duplicate.course = original.course
          duplicate.task_number = original.task_number
          duplicate.is_team_deliverable = original.is_team_deliverable
          duplicate.team_id = original.team_id
          duplicate.should_not be_valid
      end
    end
  end
  context "should return current attachments" do
    it "should return the most recent one" do

      deliverableA = Factory.build(:deliverable_attachment)
      deliverable = Deliverable.first
      deliverableA.submitter = Person.find_by_last_name("Sam")
      deliverableA.submission_date = Date.today - 1


      deliverableB = DeliverableAttachment.new(:submitter => deliverableA.submitter)
      deliverableA.submission_date = Date.today
      deliverable.attachment_versions << deliverableB
      deliverable.save
      deliverable = Deliverable.first
      deliverable.current_attachment.should == deliverableB

    end
  end
  context "Owner name" do
    it "should return the correct team name if team deliverable" do
      deliverable = Factory.build(:team_deliverable)
      deliverable.owner_name.should == "Team Triumphant"
    end
    it "should return correct creator name if individual" do
      deliverable = Factory.build(:individual_deliverable)
      deliverable.owner_name.should == "Student Sam"
    end
  end
  context "owner_email" do
     it "should return the correct team name if team deliverable" do
      deliverable = Factory.build(:team_deliverable)
      deliverable.owner_email.should == "fall-2011-team-triumphant@sandbox.sv.cmu.edu"
    end
    it "should return correct creator name if individual" do
      deliverable = Factory.build(:individual_deliverable)
      deliverable.owner_email.should == "student.sam@sv.cmu.edu"
    end
  end
  context "find current by person" do
    it "should find deliverables for individual" do
      deliverable = Factory(:individual_deliverable)
      deliverable2 = Deliverable.create(deliverable.attributes)
      deliverable2.name = "DEFECT"
      deliverable2.creator = deliverable.creator
      deliverable2.course = deliverable.course
      deliverable.team_id = nil
      deliverable2.save
      person = Person.find_by_last_name("Sam")
      Deliverable.find_current_by_person(person)[0].should == deliverable
      Deliverable.find_current_by_person(person).should == Deliverable.find_all_by_course_id(deliverable2.course_id)
    end
    it "should find deliverables for team" do
      deliverable = Factory(:team_deliverable)
      person = Person.find_by_last_name("Sam")
      Deliverable.find_current_by_person(person)[0].should == deliverable
    end
  end

  it "should return team name for a team deliverable" do
    deliverable = Factory.build(:team_deliverable)
    deliverable.stub(:update_team)
    deliverable.save
    deliverable.owner_name.should be_equal(deliverable.team.name)
  end

    it "should return person name for a individual deliverable" do
    deliverable = Factory(:individual_deliverable)
    deliverable.owner_name.should be_equal(deliverable.creator.human_name)
  end

  it "should return team email for a team deliverable" do
    deliverable = Factory.build(:team_deliverable)
    deliverable.stub(:update_team)
    deliverable.save
    deliverable.owner_email.should be_equal(deliverable.team.email)
  end

  it "should return person email for a individual deliverable" do
    deliverable = Factory(:individual_deliverable)
    deliverable.owner_email.should be_equal(deliverable.creator.email)
  end

  context "has_feeback?" do
  it "returns false when there is no feedback" do
    subject.has_feedback?.should be_false

#!(self.feedback_comment.nil? or self.feedback_comment == "") or !self.feedback_file_name.nil?
  end

  it "returns true when there is a comment" do
    subject.feedback_comment = "Great job team!"
    subject.has_feedback?.should be_true
  end

  it "returns true when there is a file" do
    subject.feedback_file_name = "/somewhere_on_s3/somewhere_over_the_rainbow/amazing_feedback.txt"
    subject.has_feedback?.should be_true
  end


  end

  context "for a team" do
    before(:each) do
      @deliverable = Factory.build(:team_deliverable)
      @team_member = @deliverable.team.people[0]
    end

    it "is not editable by any random student" do
      @deliverable.editable?(Factory(:student_sally)).should be_false
    end

    it "is editable by staff or admin" do
      @deliverable.editable?(Factory(:faculty_frank)).should be_true
     end

    it "is editable by a team member" do
      @deliverable.editable?(@team_member).should be_true
    end
  end

  context "for an individual deliverable" do
    before(:each) do
      @deliverable = Factory.build(:individual_deliverable)
      @individual = @deliverable.creator
    end

    it "is not editable by any random student" do
      @deliverable.editable?(Factory(:student_sally)).should be_false
    end

    it "is editable by staff or admin" do
      @deliverable.editable?(Factory(:faculty_frank)).should be_true
     end

    it "is editable by its owner" do
      @deliverable.editable?(@individual).should be_true
    end
  end







end


