# frozen_string_literal: true

RSpec.describe Outdated::CLI do
  describe '.run' do
    subject(:run) { described_class.run }

    let(:definition) { double(resolve_remotely!: true) }
    let(:spec_set) { Outdated::RubyGems::SpecSet.new(specs) }
    let(:specs) { [] }
    let(:spec) do
      double(version: Gem::Version.new('1.2.3'),
             name: SecureRandom.hex,
             prerelease: false,
             created_at: Time.now - 8 * 7 * 24 * 60 * 60)
    end

    before do
      allow(Bundler).to receive(:definition).and_return(definition)
      allow(Bundler.definition).to receive(:resolve).and_return(specs)
      allow(Bundler.load).to receive(:dependencies).and_return(specs)
      allow(Outdated::RubyGems)
        .to receive(:spec_set).and_return(spec_set)
    end

    context "when no specs are found" do
      it { is_expected.to eq(0) }
    end

    context "when a spec is found" do
      let(:specs) { [spec] }

      it { is_expected.to eq(0) }
    end
  end
end
