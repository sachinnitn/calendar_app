require "google/apis/calendar_v3"
require "google/api_client/client_secrets.rb"

module GoogleCalendarApi

  include ActiveSupport::Concern

  def get_google_calendar_client(current_user)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless (current_user.present? && current_user.access_token.present? && current_user.refresh_token.present?)

    secrets = Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => current_user.access_token,
        "refresh_token" => current_user.refresh_token,
        "client_id" => ENV['GOOGLE_CLIENT_ID'],
        "client_secret" => ENV['GOOGLE_CLIENT_SECRET']
      }
    })
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = "refresh_token"

      if current_user.expired?
        client.authorization.refresh!
        current_user.update(
          access_token: client.authorization.access_token,
          refresh_token: client.authorization.refresh_token,
          expires_at: client.authorization.expires_at.to_i
        )
      end
    rescue => e
      puts e.message
    end
    client
  end

  def create_google_event(event)
    client = get_google_calendar_client(event.user)
    g_event = get_event(event)
    ge = client.insert_event(Event::CALENDAR_ID, g_event)
    event.update(google_event_id: ge.id)
  end

  def add_quick_google_event(event, user)
    client = get_google_calendar_client user
    ge = client.quick_add_event(Event::CALENDAR_ID, event.title)
    event.update(google_event_id: ge.id)
  end

  def edit_google_event(event)
    client = get_google_calendar_client(event.user)
    g_event = client.get_event(Event::CALENDAR_ID, event.google_event_id)
    ge = get_event(event)
    client.update_event(Event::CALENDAR_ID, event.google_event_id, ge)
  end

  def get_event(event)
    event = Google::Apis::CalendarV3::Event.new({
      summary: event.title,
      location: event.venue,
      description: event.description,
      start: {
        date_time: event.start_date.to_datetime.to_s,
        time_zone: 'Asia/Kolkata',
      },
      end: {
        date_time: event.end_date.to_datetime.to_s,
        time_zone: 'Asia/Kolkata',
      },
      organizer: {
        email: event.user.email,
        displayName: event.user.name
      },
      attendees: event_attendees(event),
      reminders: {
        use_default: false
      },
      sendNotifications: true,
      sendUpdates: 'all'
    })
  end

  def delete_google_event(event)
    client = get_google_calendar_client(event.user)
    client.delete_event(Event::CALENDAR_ID, event.google_event_id)
  end

  def get_google_event(event_id, user)
    client = get_google_calendar_client user
    g_event = client.get_event(Event::CALENDAR_ID, event_id)
  end

  def event_attendees(event)
    event.email_guest_list.map {|guest| { email: guest, displayName: guest.split('@')[0], organizer: false }} << { email: event.user.email, displayName: event.user.name, organizer: true}
  end

  def sync_existing_events(user)
    events=fetch_events_from_calendar(user)
    event_items = events.items

    event_items&.each do |ev|
      event = Event.find_by(google_event_id: ev.id)
      if event
        update_event_in_db(event, ev)
      else
        create_event_in_db(ev, user)
      end
    end
    delete_stale_events(event_items, user) if event_items.present?
  end

  def fetch_events_from_calendar(user)
    client = get_google_calendar_client(user)
    client.list_events(Event::CALENDAR_ID)
  end

  def update_event_in_db(event, google_event)
    event.update_columns(generate_event_attrs(google_event))
  end

  def create_event_in_db(ev, user)
    Event.create!(
      created_at: ev.created,
      updated_at: ev.updated,
      description: ev.description,
      start_date: ev.start.date_time,
      end_date: ev.end.date_time,
      venue: ev.location,
      title: ev.summary,
      user_id: user.id,
      google_event_id: ev.id,
      guest_list: ev.attendees&.map {|attendee| attendee.email}&.join(", ")
    )
  end

  def generate_event_attrs(ev)
    {
      description: ev.description,
      start_date: ev.start.date_time,
      end_date: ev.end.date_time,
      venue: ev.location,
      title: ev.summary,
      guest_list: ev.attendees&.map {|attendee| attendee.email}&.join(", ")
    }
  end

  def delete_stale_events(event_items, user)
    Event.where(user_id: user.id).where.not(google_event_id: event_items.map(&:id)).delete_all
  end
end
