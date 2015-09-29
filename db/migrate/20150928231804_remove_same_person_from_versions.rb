class RemoveSamePersonFromVersions < ActiveRecord::Migration
  def change
    VestalVersions::Version.transaction do
      VestalVersions::Version.where("modifications like ?", "%other_people_with_same_name%").each do |v|
        modifications = v.modifications["other_people_with_same_name"]
        if modifications.nil?
          raise "No other_people_with_same_name modifications for version #{v.id}"
        elsif modifications.first.is_a?(Array)
          v.modifications["other_people_with_same_name"] = [ true, false ]
        elsif modifications.last.is_a?(Array)
          v.modifications["other_people_with_same_name"] = [ false, true ]
        else
          p modifications
          raise "No array found"
        end
        v.save!
      end
    end
  end
end
