# frozen_string_literal: true

RSpec.describe Outdated do
  it 'has a version number' do
    expect(Outdated::VERSION).not_to be nil
  end
end
