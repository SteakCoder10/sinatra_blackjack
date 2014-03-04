require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    hand = cards.map{|card| card[0]}
    total = 0
    hand.each do |idv_card|
      if idv_card.to_s == "Ace"
        total += 11
      elsif (idv_card.to_s == "King" or idv_card.to_s == "Queen" or idv_card.to_s == "Jack")
        total += 10
      else
        total += idv_card.to_i
      end
    end
    hand.select{|val| val == "Ace"}.count.times do
      break if total <= 21
      total -= 10
    end
    total
  end
end

get '/' do
    erb :set_name
end

post '/name_set' do
  session[:player_name] = params[:player_name]
  redirect "/game"
end

get "/game" do
  session[:deck] = []
  card_values = ["2","3","4","5","6","7","8","9","10","Jack","Queen","King","Ace"]
  card_suits = ["Hearts","Diamonds","Spades","Clubs"]
  card_values.each do |card|
    card_suits.each do |suit|
      session[:deck] << [card,suit]
    end
  end

  session[:deck].shuffle!
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  erb :game
end
