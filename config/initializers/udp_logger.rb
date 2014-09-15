if Rails.env.production? || Rails.env.staging?
  udp_logger = ::LogStashLogger.new(port: 5228)
  parameter_filter = ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)

  ActiveSupport::Notifications.subscribe(/fragment|process_action.action_controller|racing_on_rails/) do |name, start, finish, id, payload|
    if payload[:status] && payload[:status].is_a?(Fixnum)
      payload[:status] = payload[:status].to_s
      puts "payload[:status] #{payload[:status]} #{payload[:status].class}"
    end

    message = {
      current_person_name: ::Person.current.try(:name),
      current_person_id: ::Person.current.try(:id),
      duration: (finish - start),
      id: id,
      message: name,
      racing_association: RacingAssociation.current.short_name,
      start: start
    }.merge(
      parameter_filter.filter payload
    )

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
