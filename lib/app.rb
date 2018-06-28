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
    when '/check' then check_guess
    else Rack::Response.new('Not found', 404)
    end
  end

  private

  def player_name
    @request.session[:player_name]
  end

  def player_name_set(name)
    @request.session[:player_name] = name
  end

  def index
    if @request.params['player_name']
      @request.session[:game] = Codebreaker::Game.new(player_name) unless @request.session[:game]
      player_name_set(@request.params['player_name']) unless @request.session[:player_name]
    end
    Rack::Response.new(render 'index')
  end

  def check_guess
    # @request.session[:game].make_attempt(@request.params['breaker_code'])
    add_to_log
    redirect '/'
  end

  def add_to_log
    @request.session[:history] = @request.session[:history] || []
    @request.session[:history] << [@request.session[:guess], @request.session[:game].attempt_result]
  end

  def render(template)
    path = File.expand_path("../views/#{template}.html.erb", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def redirect(path)
    Rack::Response.new do |response|
      response.redirect("#{path}")
    end
  end
end
