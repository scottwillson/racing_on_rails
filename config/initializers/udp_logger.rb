if Rails.env.production? || Rails.env.staging?
  udp_logger = ::LogStashLogger.new(port: 5228)

  ActiveSupport::Notifications.subscribe(/fragment|process_action.action_controller|racing_on_rails/) do |name, start, finish, id, payload|
    message = {
      current_person_name: ::Person.current.try(:name),
      current_person_id: ::Person.current.try(:id),
      duration: (finish - start),
      id: id,
      message: name,
      racing_association: RacingAssociation.current.short_name,
      start: start
    }.merge(payload)

    # Ideally, would traverse params and fix encodings
    begin
      udp_logger.info message
    rescue Encoding::UndefinedConversionError => e
      Rails.logger.debug "[#{Time.zone.now}] (#{e}) logging to Logstash #{message[:params]}"
      message.delete(:params)
      udp_logger.info message
    end
  end
end
