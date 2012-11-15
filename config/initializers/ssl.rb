begin
  RacingOnRails::Application.config.force_ssl = RacingAssociation.current.ssl?  
rescue ActiveRecord::StatementInvalid => e
  logger.warn "#{e} when loading RacingAssociation model. Table racing_associations might not exist."
end
