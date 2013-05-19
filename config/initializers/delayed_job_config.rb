Delayed::Worker.destroy_failed_jobs = false      # default true
Delayed::Worker.sleep_delay         = 3          # default 5 sec.
Delayed::Worker.max_attempts        = 5          # default 25
Delayed::Worker.max_run_time        = 60.minutes # default 4.hours
Delayed::Worker.read_ahead          = 15         # default 5

Delayed::Worker.logger = ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_jobs.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1
if caller.last =~ /.*\/script\/delayed_job:\d+$/
  ActiveRecord::Base.logger = Delayed::Worker.logger
end

