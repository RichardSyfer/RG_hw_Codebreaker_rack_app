# frozen_string_literal: true

require_relative './spec_helper.rb'

feature App do
  describe 'index page' do
    before { visit '/' }
    scenario 'show login form to new user' do
      expect(page).to have_content 'Welcome to Codebreaker!'
      expect(page).to have_button 'Let\'s play'
    end

    context 'when user log in' do
      before do
        fill_in 'player_name', with: 'John Kramer'
        click_button 'Let\'s play'
      end

      scenario 'show game interface, after user log in' do
        expect(page).to have_field 'breaker_code'
        expect(page).to have_content 'You should enter 4 digit from range 1..6'
        expect(page).to have_button 'Check guess'
        expect(page).to have_field 'hint'
        expect(page).to have_content 'hints left'
        expect(page).to have_button 'Hint'
      end

      scenario 'show remaining attempts and game log, if user enter code' do
        fill_in 'breaker_code', with: '1111'
        click_button 'Check guess'
        expect(page).to have_content 'Remaining attempts: 9'
        expect(page).to have_table 'game_log'
      end

      scenario 'show hint, if user asq about it' do
        click_button 'Hint'
        expect(page).to have_content 'You have 2 hints left.'
      end

      scenario 'show message to user and forms with buttons after game' do
        10.times do
          fill_in 'breaker_code', with: '1111'
          click_button 'Check guess'
        end
        expect(page).to have_content 'John Kramer'
        expect(page).to have_button 'Save results'
        expect(page).to have_button 'Restart game'
      end
    end
  end

  describe 'page game scores' do
    scenario 'show table with saved scores' do
      visit '/scores'
      expect(page).to have_content 'GAME SCORES'
      expect(page).to have_table 'game_scores'
    end
  end

  describe 'page 404' do
    scenario 'show 404 error response if page not found' do
      visit '/nopage'
      expect(page.status_code).to eq(404)
    end
  end
end
