# frozen_string_literal: true

require_relative 'outdated/cli'
require_relative 'outdated/ruby_gems'
require_relative 'outdated/ruby_gems/versions'
require_relative 'outdated/version'

module Outdated
  class Error < StandardError; end
end
