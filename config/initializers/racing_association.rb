# No way around an exception when creating racing_associations table
begin
  ASSOCIATION = RacingAssociation.first || RacingAssociation.create!

  ASSOCIATION_SHORT_NAME = ASSOCIATION.short_name || "CBRA"
  ASSOCIATION_DEFAULT_SANCTIONED_BY = ASSOCIATION.default_sanctioned_by || "CBRA"
rescue Exception => e
  puts e
end
