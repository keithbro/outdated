# frozen_string_literal: true

RSpec.describe Outdated::RubyGems::Gem do
  subject(:spec_set) { described_class.new(specs) }

  let(:new_immature_spec) { Outdated::RubyGems::Spec.new(created_at: 1.weeks.ago, version: Gem::Version.new('1.2.4')) }
  let(:new_mature_spec) { Outdated::RubyGems::Spec.new(created_at: 3.weeks.ago, version: Gem::Version.new('1.2.4')) }
  let(:mature_spec) { Outdated::RubyGems::Spec.new(created_at: 4.weeks.ago, version: Gem::Version.new('1.2.3')) }
  let(:old_mature_spec) { Outdated::RubyGems::Spec.new(created_at: 5.weeks.ago, version: Gem::Version.new('1.2.2')) }
  let(:cut_off) { 2.weeks.ago }

  let(:specs) { [mature_spec] }

  describe '.from_response' do
    subject(:spec_set) { described_class.from_response(response) }

    context "when the response contains a spec" do
      let(:created_at) { 4.weeks.ago }
      let(:version) { Gem::Version.new('1.2.3') }
      let(:body) { JSON.generate([{ created_at: created_at.iso8601(6), number: version.to_s }]) }

      let(:response) { double(code: 200, body: body) }

      it { is_expected.to be_a(Outdated::RubyGems::Gem) }
      it { expect(spec_set.first.created_at).to eq(created_at) }
      it { expect(spec_set.first.version).to eq(version) }
    end

    context "when the response was a 404" do
      let(:response) { double(code: 404) }

      it { is_expected.to be_a(Outdated::RubyGems::Gem) }
      it { is_expected.to be_empty }
    end
  end

  describe '#recommend' do
    subject(:recommend) { spec_set.recommend(currently_used_spec, cut_off) }

    let(:currently_used_spec) { mature_spec }

    context "when the only available spec is the one that is used" do
      let(:specs) { [currently_used_spec] }

      it { is_expected.to eq([currently_used_spec, nil]) }
    end

    context "when a new patch is available but it's too new" do
      let(:specs) { [new_immature_spec, currently_used_spec] }

      it { is_expected.to eq([currently_used_spec, nil]) }
    end

    context "when a new patch is available and sufficiently old" do
      let(:specs) { [new_mature_spec, currently_used_spec] }

      it { is_expected.to eq([new_mature_spec, Outdated::OUTDATED]) }
    end

    context "when the currently used spec is too new" do
      let(:specs) { [old_mature_spec, currently_used_spec] }

      it { is_expected.to eq([old_mature_spec, Outdated::IMMATURE]) }
    end

    context "when there are no recommendations" do
      let(:specs) { [currently_used_spec] }
      let(:currently_used_spec) { new_immature_spec }

      it { is_expected.to eq([nil, Outdated::IMMATURE]) }
    end
  end
end
