# frozen_string_literal: true

require './lib/app'

use Rack::Reloader
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'

run Rack::Cascade.new([Rack::File.new('public'), App])
