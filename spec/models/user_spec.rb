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

  describe '#first_login?' do
    let(:user) { create(:user, sign_in_count: sign_in_count) }

    context 'when the user has not logged in previously' do
      let(:sign_in_count) { 0 }

      it 'returns true' do
        expect(user.first_login?).to eq(true)
      end
    end

    context 'when the user has logged in previously' do
      let(:sign_in_count) { 2 }

      it 'returns false' do
        expect(user.first_login?).to eq(false)
      end
    end
  end

  describe '#name' do
    let(:user) { create(:user, first_name: first_name, last_name: last_name) }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:full_name) { "#{first_name} #{last_name}" }

    it 'returns the full name' do
      expect(user.name).to eq(full_name)
    end
  end
end
