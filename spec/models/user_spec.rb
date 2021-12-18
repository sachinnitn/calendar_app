require 'rails_helper'

describe 'User' do
  let(:user) { create(:user, expires_at: expires_at) }

  describe '#expired?' do
    context 'when the token is expired' do
      let(:expires_at) { 2.days.ago }

      it 'returns true' do
        expect(user.expired?).to eq(true)
      end
    end

    context 'when the token is not expired' do
      let(:expires_at) { 2.days.from_now }

      it 'returns false' do
        expect(user.expired?).to eq(false)
      end
    end
  end
end
