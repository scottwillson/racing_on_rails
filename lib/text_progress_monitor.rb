include ProgressMonitor

class TextProgressMonitor
  def increment(value)
    print('.')
  end
  
  def progress=(value) 

  end
  
  def progress
  end
  
  def total=(value) 
  end
  
  def text=(value) 
    puts(value)
    @text = value
  end

  def detail_text=(value)
    puts("#{@text}: #{value}")
  end

  def enable
    @text = ""
  end
end
