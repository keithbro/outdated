# frozen_string_literal: true

RSpec.describe Outdated::RubyGems::SpecSet do
  subject(:spec_set) { described_class.new(specs) }

  let(:new_immature_spec) { OpenStruct.new(created_at: 1.weeks.ago, version: Gem::Version.new('1.2.4')) }
  let(:new_mature_spec) { OpenStruct.new(created_at: 3.weeks.ago, version: Gem::Version.new('1.2.4')) }
  let(:mature_spec) { OpenStruct.new(created_at: 4.weeks.ago, version: Gem::Version.new('1.2.3')) }
  let(:old_mature_spec) { OpenStruct.new(created_at: 5.weeks.ago, version: Gem::Version.new('1.2.2')) }
  let(:cut_off) { 2.weeks.ago }

  let(:specs) { [mature_spec] }

  describe '.from_response' do
    subject(:spec_set) { described_class.from_response(response) }

    context "when the response contains a spec" do
      let(:response) do
        double(code: 200, body: JSON.generate([{ created_at: 4.weeks.ago.iso8601, number: '1.2.3' }]))
      end

      it { is_expected.to be_a(Outdated::RubyGems::SpecSet) }
      it { expect(spec_set.first.version).to eq(Gem::Version.new('1.2.3')) }
    end

    context "when the response was a 404" do
      let(:response) { double(code: 404) }

      it { is_expected.to be_a(Outdated::RubyGems::SpecSet) }
      it { is_expected.to be_empty }
    end
  end

  describe '#recommend' do
    subject(:recommend) { spec_set.recommend(status_quo_spec, cut_off) }

    let(:status_quo_spec) { mature_spec }

    context "when the only available spec is the one that is used" do
      let(:specs) { [status_quo_spec] }

      it { is_expected.to eq(status_quo_spec) }
    end

    context "when a new patch is available but it's too new" do
      let(:specs) { [new_immature_spec, status_quo_spec] }

      it { is_expected.to eq(status_quo_spec) }
    end

    context "when a new patch is available and sufficiently old" do
      let(:specs) { [new_mature_spec, status_quo_spec] }

      it { is_expected.to eq(new_mature_spec) }
    end

    context "when the currently used spec is too new" do
      let(:specs) { [old_mature_spec, status_quo_spec] }

      it { is_expected.to eq(old_mature_spec) }
    end
  end
end
