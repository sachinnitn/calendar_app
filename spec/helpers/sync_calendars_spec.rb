require 'rails_helper'

describe 'SyncCalendars' do
  let(:user) { create(:user) }
  let!(:event) { create(:event, user: user) }

  describe '#process!' do
    context 'when the job is run' do
      let(:subject) { SyncCalendars.call }

      it 'returns true' do
        allow_any_instance_of(GoogleCalendarApi).to receive(:sync_existing_events).once
        subject
        expect(Delayed::Job.count).to eq(1)
      end
    end
  end
end
