require 'codebreaker/game'

class App
  def call(env)
    [200, { 'Content-Type' => 'text/plain' }, ['Init commit. Rack app']]
  end
end
