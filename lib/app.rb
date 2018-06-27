# frozen_string_literal: true

require 'erb'
require 'codebreaker/game'

class App
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/' then index
    else Rack::Response.new('Not found', 404)
    end
  end

  private

  def index
    Rack::Response.new(render 'index')
  end

  def render(template)
    path = File.expand_path("../views/#{template}.html.erb", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
