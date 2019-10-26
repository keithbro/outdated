# frozen_string_literal: true

RSpec.describe Outdated::RubyGems::SpecSet do
  subject(:spec_set) { described_class.new(specs) }

  let(:spec) do
    OpenStruct.new(created_at: 5.weeks.ago, version: Gem::Version.new('1.2.3'))
  end

  let(:specs) { [spec] }

  describe '.from_response' do
    subject(:spec_set) { described_class.from_response(response) }

    let(:response) do
      double(code: 200, body: JSON.generate([{ created_at: 5.weeks.ago.iso8601, number: '1.2.3' }]))
    end

    it { is_expected.to be_a(Outdated::RubyGems::SpecSet) }
    it { expect(spec_set.first.version).to eq(Gem::Version.new('1.2.3')) }
  end

  describe '#recommend' do
    subject(:recommend) { spec_set.recommend(status_quo_spec, cut_off) }

    let(:cut_off) { 2.weeks.ago }

    context "when the only available spec is the one that is used" do
      let(:status_quo_spec) { spec }

      it 'recommends the status quo' do
        expect(recommend).to eq(status_quo_spec)
      end
    end
  end
end
