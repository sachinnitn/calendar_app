class SyncCalendars
  include GoogleCalendarApi

  def self.call
    new.process!
  end

  def process!
    User.all.each { |user| sync_existing_events(user) }

    enqueue_sync_job
  end

  private

  def enqueue_sync_job
    Delayed::Job.all.delete_all
    SyncCalendars.delay(run_at: ENV.fetch('CALENDAR_SYNC_DURATION', 2)
                 .to_i.minutes.from_now).call
  end
end
