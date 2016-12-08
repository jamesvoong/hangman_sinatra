require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions

get '/' do
	if session[:remaining_guesses].nil?
		new_game
	elsif game_over?
		redirect to('/game_over')	
	end
	erb :index, :locals => {:remaining_guesses => session[:remaining_guesses], :remaining_letters => session[:remaining_letters], :correct_letters => session[:correct_letters].join(" "), :color => session[:color]}
end

get '/game_over' do
	if session[:remaining_guesses] == 0
		message = "Oh no! Better luck next time! The word was: #{session[:word]}."
	else
		message = "Good job! You found the word: #{session[:word]}."
	end

	erb :game_over, :locals => {:message => message, :color => session[:color]}
end

get '/new_game' do
	new_game
	redirect to('/')
end

post '/' do
	if valid_guess?params[:user_guess]
		current_turn(params[:user_guess])
		change_color
	end
	redirect to('/')
end

helpers do
	def new_game
		session[:word] = random_word
		session[:remaining_guesses] = 5
		session[:remaining_letters] = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
		session[:correct_letters] = []
		session[:word].split("").each {|x| session[:correct_letters] << "_"}
		change_color
	end

	def random_word
		words = File.readlines "5desk.txt"
		numberOfWords = words.size
		chosenWord = ""

		while (chosenWord.size < 5) || (chosenWord.size > 12)
			chosenWord = words[rand(numberOfWords)%numberOfWords]
		end

		chosenWord.strip
	end

	def valid_guess?(user_guess)
		user_guess.length > 1 || !session[:remaining_letters].split("").include?(user_guess.upcase) ? false : true	
	end

	def current_turn(user_guess)
		found_positions = (0...session[:word].length).find_all {|i| session[:word][i].downcase == user_guess.downcase}

		session[:remaining_letters] = session[:remaining_letters].sub(user_guess.upcase, " ")

		if found_positions.empty?
			session[:remaining_guesses] -= 1
		else
			found_positions.each {|i| session[:correct_letters][i] = session[:word].split("")[i]}
		end
	end

	def game_over?
		session[:remaining_guesses] == 0 || session[:correct_letters].join == session[:word] ? true : false
	end

	def change_color
		case session[:remaining_guesses]
		when 5
			session[:color] = "white"
		when 4
			session[:color] = "#F0E68C"
		when 3
			session[:color] = "#DAA520"
		when 2
			session[:color] = "#FFA500"
		when 1
			session[:color] = "#FF4500"
		when 0
			session[:color] = "red"
		end
	end
end