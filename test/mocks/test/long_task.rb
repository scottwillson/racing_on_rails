# Same as prod, but synchronous
module LongTask

  # Pass task in as a block. 
  # Example: long_task() {Bar.calculate(2006)}
  def long_task(task_name = '')
    if !@doing_long_task
      @doing_long_task = true
      # TODO Add disable all method
      @progress_frame.enable
			getApp.beginWaitCursor	  

      begin
        yield
      rescue Exception => error
        stack_trace = $!.backtrace.join("\n")
        RACING_ON_RAILS_DEFAULT_LOGGER.error("#{$!}\n#{stack_trace}")
        FXMessageBox.error(self, MBOX_OK, "Error", "Could not #{task_name} because of an error: \n#{$!}")
      ensure
        @progress_frame.disable
        getApp.endWaitCursor	  
        @doing_long_task = false
      end
    end
  end
end