require 'rubygems'
require 'sinatra'

enable :sessions

helpers do
  def calculate_total(cards)
    hand = cards.map{|card| card[0]}
    total = 0
    hand.each do |idv_card|
      if idv_card.to_s == "ace"
        total += 11
      elsif (idv_card.to_s == "king" or idv_card.to_s == "queen" or idv_card.to_s == "jack")
        total += 10
      else
        total += idv_card.to_i
      end
    end
    hand.select{|val| val == "ace"}.count.times do
      break if total <= 21
      total -= 10
    end
    total
  end
  
  def show_card(card)
    "/images/cards/" + card[1].to_s + "_" + card[0].to_s + ".jpg"
  end

  def determine_winner(player_card_total,dealer_card_total)
    if (session[:dealer_status] == "Busted" and session[:player_status] != "Busted")
      "The player wins!"
    elsif (session[:dealer_status] != "Busted" and session[:player_status] == "Busted")
      "The dealer wins!"
    elsif player_card_total > dealer_card_total
      "The player wins!"
    elsif player_card_total < dealer_card_total
      "The dealer wins!"
    else
      "It's a draw!"
    end

  end

end

get '/' do
  if session[:player_name]
    redirect "/game"
  else
    erb :set_name
  end
end

post '/name_set' do
  session[:player_name] = params[:player_name]
  redirect "/game"
end

get "/game" do
  session[:dealer_status] = "playing"
  session[:player_status] = ""
  session[:winner] = ""
  session[:deck] = []
  card_values = ["2","3","4","5","6","7","8","9","10","jack","queen","king","ace"]
  card_suits = ["hearts","diamonds","spades","clubs"]
  card_values.each do |card|
    card_suits.each do |suit|
      session[:deck] << [card,suit]
    end
  end

  session[:deck].shuffle!
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  session[:dealer_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) == 21
    session[:player_status] = "Blackjack"
  end

  erb :game
end

post '/player_hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    session[:player_status] = "Busted"
  elsif calculate_total(session[:player_cards]) == 21
    session[:player_status] = "Blackjack"
  end
  erb :game
end

post '/player_stand' do
  while session[:dealer_status] == "playing"
    if calculate_total(session[:dealer_cards]) > 21
      session[:dealer_status] = "Busted"
    elsif calculate_total(session[:dealer_cards]) > 16
      session[:dealer_status] = "Done"
    else
      session[:dealer_cards] << session[:deck].pop
    end
  end
  
  session[:winner] = determine_winner(calculate_total(session[:player_cards]), calculate_total(session[:dealer_cards]))
  erb :game
end
