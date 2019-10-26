# frozen_string_literal: true

RSpec.describe Outdated::CLI do
  describe '.run' do
    subject(:run) { described_class.run }

    let(:definition) { double(resolve_remotely!: true) }
    let(:gem) { Outdated::RubyGems::Gem.new(remote_specs) }
    let(:remote_specs) { [spec] }
    let(:currently_used_specs) { [spec] }
    let(:spec) do
      Outdated::RubyGems::Spec.new(version: Gem::Version.new('1.2.3'),
                                   name: SecureRandom.hex,
                                   prerelease: false,
                                   created_at: 8.weeks.ago)
    end

    before do
      allow(Bundler).to receive(:definition).and_return(definition)
      allow(Bundler.definition).to receive(:resolve).and_return(currently_used_specs)
      allow(Outdated::RubyGems).to receive(:gem).and_return(gem)
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

    context "when there are no remote specs" do
      let(:currently_used_specs) { [spec] }
      let(:remote_specs) { [] }

      it { is_expected.to eq(0) }
    end

    context "when there are remote specs but no recommended ones" do
      let(:currently_used_specs) { [spec] }
      let(:remote_specs) { [spec] }

      before { allow(gem).to receive(:recommend).and_return([nil, Outdated::IMMATURE]) }

      it { is_expected.to eq(1) }
    end

    context "when there are remote specs, no recommended ones but the gem is excluded" do
      let(:currently_used_specs) { [spec] }
      let(:remote_specs) { [spec] }
      let(:config) { { exclusions: [{ "gem": gem.name, rules: [Outdated::IMMATURE] }] } }

      before do
        allow(gem).to receive(:recommend).and_return([nil, Outdated::IMMATURE])
        allow(File)
          .to receive(:read)
          .and_return(JSON.generate(config))
      end

      it { is_expected.to eq(0) }
    end
  end
end
