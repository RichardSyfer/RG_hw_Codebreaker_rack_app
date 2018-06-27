# frozen_string_literal: true

require './lib/app'

use Rack::Reloader, 0

run Rack::Cascade.new([Rack::File.new('public'), App])
