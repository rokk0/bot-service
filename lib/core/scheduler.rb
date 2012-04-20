require 'rubygems'
require 'rufus/scheduler'

# TODO: this
module Core
  class Scheduler

    # here goes params (interval, count)
    def initialize(params)
      @scheduler = Rufus::Scheduler.start_new
    end

    def add_worker(worker)
      # return tag
    end
      
    def get_worker(by_tag)
    end

    def all_jobs
      @scheduler.all_jobs
    end

  end
end
