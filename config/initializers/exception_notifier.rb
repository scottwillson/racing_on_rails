begin
  # ExceptionNotifier.exception_recipients = (RacingAssociation.current.try(:exception_recipients) || "scott.willson@gmail.com")
rescue Exception => e
  puts(e)
end
