require 'spec_helper'

RSpec.describe QuickbooksWebConnector::User do

  subject(:user) { described_class.new('jane', 'top-secret', '/path/to/company.qbw') }

  it 'uses a default owner_id/file_id when none provided' do
    expect(user.owner_id).to eq('d69682e6-4436-44bc-bd19-d6bfbd11778d')
    expect(user.file_id).to eq('916222f3-c574-4c70-8c9d-e3cec2634e49')
  end

  it 'allows specifying the owner_id/file_id to override the default on initializing' do
    user = described_class.new('jane', 'top-secret', '/path/to/company.qbw', '294e582d-4feb-4174-b1a8-42d524790144', '1a793198-9303-4b96-86f6-1fb359e0ae22')

    expect(user.owner_id).to eq('294e582d-4feb-4174-b1a8-42d524790144')
    expect(user.file_id).to eq('1a793198-9303-4b96-86f6-1fb359e0ae22')
  end

  describe '#valid_password?' do
    it 'returns true when the provided password matches' do
      expect(user.valid_password?('top-secret')).to be(true)
    end

    it 'returns false when the provided password does not match' do
      expect(user.valid_password?('secret')).to be(false)
    end
  end

end
