require File.join(Rails.root,'spec','factories','factories.rb')
Factory.define :team_triumphant, :parent => :team do |t|
 t.name "Team Triumphant"
 t.email "triumphant@sv.cmu.edu"
 t.tigris_space "http://triumphant.tigris.org/servlets/ProjectDocumentList"
 t.twiki_space "http://info.sv.cmu.edu/twiki/bin/view/Graffiti/WebHome"
 t.association :course, :factory => :course
 t.after_create { |t| Factory(:student_sam, :teams => [t], :login => "student_sam_random", :webiso_account => Time.now.to_f.to_s + "@andrew.cmu.edu")}
 t.after_create { |t| Factory(:student_sally, :teams => [t], :login => "student_sally_random", :webiso_account => Time.now.to_f.to_s + "@andrew.cmu.edu")}

end

Factory.define :deuce_ace, :parent => :team do |t|
 t.name "Team Deuce Ace"
 t.email "deuceace@sv.cmu.edu"
 t.tigris_space "http://deuceace.tigris.org/servlets/ProjectDocumentList"
 t.twiki_space "http://info.sv.cmu.edu/twiki/bin/view/Graffiti/WebHome"
 t.association :course, :factory => :course
 t.after_create { |t| Factory(:student_sam, :teams => [t], :login => "student_sam_random", :webiso_account => Time.now.to_f.to_s + "@andrew.cmu.edu")}
end
