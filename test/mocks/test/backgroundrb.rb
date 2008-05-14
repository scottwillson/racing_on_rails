module BackgrounDRb
  class WorkerProxy
    def self.init
      new
    end

    def self.ask_work(args)
      @@worker_instance.send(args[:worker_method], args[:data])
    end

    def initialize
    end
  
    def worker(worker_name)
      @@worker_instance = eval("#{worker_name.to_s.camelize}.new")
      @@worker_instance
    end
  end
end

MiddleMan = BackgrounDRb::WorkerProxy.init
