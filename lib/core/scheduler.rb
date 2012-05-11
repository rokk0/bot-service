module Core
  class Scheduler

    include Logging

    def self.add_job(bot)
      status = { :status => :info, :message => 'already running' }

      if get_bot_job(bot['id']).empty?
        worker = BotWorker.new(bot)

        # First run trick to return spam result immediately
        first_run = true

        # Bot spams outside of scheduler cycle and returns status
        worker.spam
        status          = worker.get_worker_status
        interval_check  = bot['interval'] =~ /(\d+)h(\d+)m/
        status[:status] = :sent if status[:status] != :error && interval_check == nil

        # Cycle makes first iterate at Time.now
        # So at first time we put status in job tags, but bot doesn't spam
        $scheduler.every bot['interval'], :first_at => Time.now, :tags => ["user_#{bot['user_id']}", "account_#{bot['account_id']}", "bot_#{bot['id']}"] do |job|
          worker.spam unless first_run
          first_run = false

          # Rewrite job status in tags, always ["user_<id>", "account_<id>", "bot_<id>", "<bot_status>", "<status_message>"]
          tags = job.tags[0..2]
          tags << worker.status << worker.message
          job.tags = tags

          job.unschedule if worker.status == :error
        end if worker.status != :error && interval_check != nil
      end

      status
    rescue Exception => e
      logger.error "Error while running worker in scheduler: #{e.message}"
      { :status => :error, :message => 'data error' }
    end

    def self.remove_job(bot_id)
      job = get_bot_job(bot_id)

      job.first.unschedule unless job.empty?

      { :status => :stopped, :message => 'stopped' }
    end

    def self.remove_account_jobs(account_id)
      jobs = get_account_jobs(account_id)

      jobs.each { |job| job.unschedule } unless jobs.empty?

      { :status => :stopped, :message => 'all account bots stopped' }
    end

    def self.remove_user_jobs(user_id)
      jobs = get_user_jobs(user_id)

      jobs.each { |job| job.unschedule } unless jobs.empty?

      { :status => :stopped, :message => 'all bots stopped' }
    end

    def self.get_bot_job(id)
      get_jobs("bot_#{id}")
    end

    def self.get_account_jobs(id)
      get_jobs("account_#{id}")
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
