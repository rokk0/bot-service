module Core
  class Scheduler

    def self.add_job(bot)
      status = { :status => :error, :message => 'already running' }

      if get_bot_job(bot['id']).empty?
        worker = BotWorker.new(bot)

        # First run trick to return spam result immediately
        first_run = true

        # Bot spams outside of scheduler cycle and returns status
        worker.spam
        status = worker.get_worker_status

        # Cycle makes first iterate at Time.now
        # So at first time we put status in job tags, but bot doesn't spam
        $scheduler.every "#{bot['interval']}m10s", :first_at => Time.now, :tags => ["user_#{bot['user_id']}", "bot_#{bot['id']}"] do |job|
          worker.spam unless first_run
          first_run = false

          # Rewrite job status in tags, always ["user_<id>", "bot_<id>", "<bot_status>", "<status_message>"]
          tags = job.tags[0..1]
          tags << worker.status << worker.message
          job.tags = tags

          job.unschedule if worker.status == :error
        end if worker.status != :error
      end

      status
    end

    def self.remove_job(bot_id)
      job = get_bot_job(bot_id)

      job.first.unschedule unless job.empty?

      { :status => :stopped, :message => 'stopped' }
    end

    def self.remove_user_jobs(user_id)
      jobs = get_user_jobs(user_id)

      jobs.each { |job| job.unschedule } unless jobs.empty?

      { :status => :stopped, :message => 'all bots stopped' }
    end

    def self.get_bot_job(id)
      get_jobs("bot_#{id}")
    end

    def self.get_user_jobs(id)
      get_jobs("user_#{id}")
    end

    def self.get_jobs(tag)
      $scheduler.find_by_tag(tag)
    end

    def self.get_all_jobs
      $scheduler.all_jobs
    end

  end
end
