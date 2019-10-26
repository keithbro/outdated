# frozen_string_literal: true

RSpec.describe Outdated::CLI do
  describe '.run' do
    subject(:run) { described_class.run }

    let(:spec) { double(name: 'x', version: Gem::Version.new('1.2.3')) }
    let(:specs) { [] }
    let(:ruby_gems_versions) { [] }
    let(:ruby_gems_version) do
      double(number: Gem::Version.new('1.2.3'),
             prerelease: false,
             created_at: Time.now - 8 * 7 * 24 * 60 * 60)
    end

    before do
      allow(Bundler.definition).to receive(:resolve).and_return(specs)
      allow(Outdated::RubyGems)
        .to receive(:versions).and_return(ruby_gems_versions)
    end

    context "when no specs are found" do
      it { is_expected.to eq(0) }
    end

    context "when a spec is found" do
      let(:specs) { [spec] }
      let(:ruby_gems_versions) { Outdated::RubyGems::Versions.new([ruby_gems_version]) }

      it { is_expected.to eq(0) }
    end
  end
end
