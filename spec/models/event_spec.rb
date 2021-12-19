require 'rails_helper'

describe 'Event' do
  let(:user) { create(:user) }
  let(:event) { create(:event, user: user, guest_list: guest_list) }
  let(:guest_list) { "#{Faker::Internet.email}, #{Faker::Internet.email}" }

  describe '#email_guest_list' do
    context 'when the event has a guest list' do
      let(:guest_list_array) { guest_list.split(", ") }

      it 'returns the guest list as an array' do
        expect(event.email_guest_list).to eq(guest_list_array)
      end
    end
  end

  describe '#validate_event_dates' do
    let(:event_errors) { event.errors.full_messages }

    before do
      allow_any_instance_of(GoogleCalendarApi).to receive(:edit_google_event).and_return(true)
      event.update(start_date: start_date, end_date: end_date)
    end

    context 'when the event start_date is after end_date' do
      let(:start_date) { 2.days.from_now }
      let(:end_date) { 1.day.from_now }

      it 'throws validation error' do
        expect(event_errors).to include('Start date must be less than end date')
      end
    end

    context 'when the event start_date is before end_date' do
      let(:start_date) { 1.day.from_now }
      let(:end_date) { 2.days.from_now }

      it 'allows the update' do
        expect(event_errors).not_to include('Start date must be less than end date')
        event.reload
        expect(event.start_date).to eq(start_date)
        expect(event.end_date).to eq(end_date)
      end
    end
  end
end
