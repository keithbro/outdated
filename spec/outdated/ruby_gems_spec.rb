# frozen_string_literal: true

RSpec.describe Outdated::RubyGems do
  describe '.spec_set' do
    subject(:spec_set) { described_class.spec_set(name) }

    let(:name) { 'x' }
    let(:response) do
      double(code: 200, body: JSON.generate([{ created_at: 5.weeks.ago.iso8601 }]))
    end

    before do
      allow(HTTP).to receive(:get).and_return(response)
    end

    it { is_expected.to be_a(Outdated::RubyGems::SpecSet) }
    it { expect(spec_set.size).to eq(1) }
  end
end
