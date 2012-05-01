
require 'encryptor'

module Core
  class Scheduler

    def self.add_job(bot)
      status = { :status => :error, :message => 'already running' }

      if self.get_bot_job(bot['id']).empty?
        worker = BotWorker.new(bot)
        worker.run

        first_run = true
        status    = worker.get_worker_status

        $scheduler.every "#{bot['interval']}m10s", :first_at => Time.now, :tags => ["user_#{bot['user_id']}", "bot_#{bot['id']}"] do |job|
          worker.run unless first_run
          first_run = false

          tags = job.tags[0..1]
          tags << worker.status << worker.message
          job.tags = tags

          job.unschedule if worker.status == :error
        end if worker.status != :error
      end

      status.to_json
    end

    def self.remove_job(id)
      job = self.get_bot_job(id)
      job.first.unschedule unless job.empty?
    end

    def self.get_user_bots(user_id)
      jobs      = self.get_user_jobs(user_id)
      job_tags  = {}
      bots      = {}

      jobs.each do |job|
        bot_id          = job.tags[1].scan(/bot_(\d+)/).flatten
        bots[bot_id[0]] = { :status => job.tags[2], :message => job.tags[3]} unless bot_id[0].nil?
      end

      bots.to_json
    end

    def self.get_job(tag)
      $scheduler.find_by_tag(tag)
    end

    def self.get_bot_job(id)
      get_job("bot_#{id}")
    end

    def self.get_user_jobs(id)
      get_job("user_#{id}")
    end

    def self.get_all_jobs
      $scheduler.all_jobs
    end

  end
end
