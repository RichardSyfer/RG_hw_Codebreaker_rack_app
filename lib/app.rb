# frozen_string_literal: true

require 'haml'
require 'yaml'
require 'codebreaker'
require_relative 'game_session_vars'
require_relative 'routes'

class App
  include GameSessionVars
  attr_reader :scores

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game_data_file_path = File.join(__dir__, 'game_data.yml')
    @scores = {}
  end

  def response
    page = Routes::APP_ROUTES[@request.path]
    page ? page.call(self) : Rack::Response.new(render('404'), 404)
  end

  def index
    if @request.params['player_name']
      self.player_name = @request.params['player_name'].strip unless player_name
      self.game = Codebreaker::Game.new(player_name) unless game
      game.start
    end
    Rack::Response.new(render 'index')
  end

  def check_guess
    self.guess = @request.params['breaker_code']
    game&.make_attempt(guess)
    add_to_log
    redirect_to '/'
  end

  def add_to_log
    self.game_log = game_log || []
    game_log << [guess, game&.attempt_result]
  end

  def show_hint
    self.hint = game&.hint
    redirect_to '/'
  end

  def game_restart
    @request.session.clear
    redirect_to '/'
  end

  def save_game_result
    scores_log = YAML.load_file(File.open(@game_data_file_path, 'r')) || []
    scores_log[scores_log.count + 1] = game&.game_data
    File.open(@game_data_file_path, 'w') { |f| f.write YAML.dump(scores_log.compact) }
    @request.session.clear
    redirect_to '/scores'
  end

  def show_scores
    @scores = YAML.load_file(File.open(@game_data_file_path, 'r')) if File.file?(@game_data_file_path)
    Rack::Response.new(render 'game_scores')
  end

  def render(template)
    path = File.expand_path("../views/#{template}.html.haml", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end

  def redirect_to(path)
    Rack::Response.new do |response|
      response.redirect(path.to_s)
    end
  end
end
