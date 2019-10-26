# frozen_string_literal: true

RSpec.describe Outdated::CLI do
  describe '.run' do
    subject(:run) { described_class.run }

    let(:definition) { double(resolve_remotely!: true) }
    let(:spec_set) { Outdated::RubyGems::SpecSet.new(remote_specs) }
    let(:remote_specs) { [spec] }
    let(:currently_used_specs) { [spec] }
    let(:spec) do
      double(version: Gem::Version.new('1.2.3'),
             name: SecureRandom.hex,
             prerelease: false,
             created_at: Time.now - 8 * 7 * 24 * 60 * 60)
    end

    before do
      allow(Bundler).to receive(:definition).and_return(definition)
      allow(Bundler.definition).to receive(:resolve).and_return(currently_used_specs)
      allow(Outdated::RubyGems).to receive(:spec_set).and_return(spec_set)
    end

    context "when no specs are currently used" do
      let(:currently_used_specs) { [] }
      let(:remote_specs) { [] }

      it { is_expected.to eq(0) }
    end

    context "when a spec is used and OK" do
      let(:currently_used_specs) { [spec] }
      let(:remote_specs) { [spec] }

      it { is_expected.to eq(0) }
    end

    context "when are no remote specs" do
      let(:currently_used_specs) { [spec] }
      let(:remote_specs) { [] }

      it { is_expected.to eq(0) }
    end

    context "when are remote specs but no recommended ones" do
      let(:currently_used_specs) { [spec] }
      let(:remote_specs) { [spec] }

      before { allow(spec_set).to receive(:recommend).and_return(nil) }

      it { is_expected.to eq(1) }
    end

  end
end
