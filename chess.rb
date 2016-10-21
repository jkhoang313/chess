require_relative 'pieces'
require_relative 'players'

class ChessBoard
	def initialize
		new_game
		game_start
	end

	def new_game
		@game_over = false
		@player_one = Player.new(1)
		@player_two = Player.new(2)
		puts "What is player one's name?"
		@player_one.name = gets.chomp.capitalize
		puts "What is player two's name?"
		@player_two.name = gets.chomp.capitalize
		print "\n"
	end

	def draw_board
		#make an empty board everytime and replace "nil" with the pieces
		@board = Array.new(8) {Array.new(8)}
		update_board(@player_one)
		update_board(@player_two)
		puts "#{@player_one.name} #{"\u265A".encode('utf-8')}".center(23)
		@board.each_with_index do |row, index|
			print "#{index+1}|"
			row.each do |position|
				print position == nil ? "__|" : position + "_|"
			end
			print "\n"
		end
		puts "  1  2  3  4  5  6  7  8"
		puts "#{@player_two.name} #{"\u2654".encode('utf-8')}".center(23)
		print "\n"
	end

	def	update_board(player)
		#put pieces in appropriate position in @board
		player.pieces.each do |piece_description|
			piece = change_to_unicode(player.side + piece_description[0])
			column = piece_description[1]-1
			row = piece_description[2]-1
			@board[row][column] = piece
		end
	end

	def change_to_unicode(piece_name)
		#add characters to pieces
		case piece_name
		when "Black King" then "\u265A".encode('utf-8')
		when "Black Queen" then "\u265B".encode('utf-8')
		when "Black Rook" then "\u265C".encode('utf-8')
		when "Black Bishop" then "\u265D".encode('utf-8')
		when "Black Knight" then "\u265E".encode('utf-8')
		when "Black Pawn" then "\u265F".encode('utf-8')
		when "White King" then "\u2654".encode('utf-8')
		when "White Queen" then "\u2655".encode('utf-8')
		when "White Rook" then "\u2656".encode('utf-8')
		when "White Bishop" then "\u2657".encode('utf-8')
		when "White Knight" then "\u2658".encode('utf-8')
		when "White Pawn" then "\u2659".encode('utf-8')
		end
	end

	def game_start
		until @game_over == true
			@player_one.possible_moves(@player_two.occupied)
			@player_two.possible_moves(@player_one.occupied)

			draw_board
			turn(@player_one, @player_two)
			if @player_one.check == true
				@player_two.king_checked = true 
				if @player_one.checkmate?(@player_two.pieces, @player_two.occupied, @player_two.side, @player_two.king_position, @player_one.pieces, @player_one.occupied, @player_one.side) == true
					puts "Checkmate!"
					draw_board 
					@game_over = true
				end
			@player_one.check = false	
			end
			print "\n"

			break if @game_over == true

			draw_board
			turn(@player_two, @player_one)
			if @player_two.check == true
				@player_one.king_checked = true 
				if @player_two.checkmate?(@player_one.pieces, @player_one.occupied, @player_one.side, @player_one.king_position, @player_two.pieces, @player_two.occupied, @player_two.side) == true
					puts "Checkmate!" 
					print "\n"
					draw_board
					@game_over = true
				end
			@player_two.check = false
			end
			print "\n"
		end
	end
	

	def turn(turn_player, enemy)
		@enemy_pieces = enemy.pieces
		@enemy_occupied = enemy.occupied
		@enemy_total_moves = enemy.total_possible_moves
		@enemy_king_position = enemy.king_position
		@king_position = turn_player.king_position
		@occupied = turn_player.occupied

		turn_player.update_pieces
		if turn_player.king_checked == true
			until turn_player.king_checked == false
				puts "Your King is checked!"
				turn_player.choose_piece
				turn_player.choose_move(@enemy_occupied)
				turn_player.uncheck_king?(@occupied, @king_position, @enemy_pieces, @enemy_occupied, enemy.side)
			end
		else
			turn_player.choose_piece
			turn_player.choose_move(@enemy_occupied) 
		end
		turn_player.make_move(@enemy_occupied)			
		capture_enemy(turn_player, enemy) if turn_player.capture == true
		turn_player.declare_check(enemy.occupied, @enemy_king_position)
		turn_player.update_pieces
	end


	def capture_enemy(turn_player, enemy)
		enemy.pieces.each_with_index do |piece_description, index|
			if piece_description[1] == turn_player.new_piece_pos[0] && piece_description[2] == turn_player.new_piece_pos[1]
				puts "Captured enemy #{piece_description[0]}!"
				enemy.pieces.delete_at(index)
				enemy.occupied.delete_at(index)
			end
		end
	end
end

a = ChessBoard.new
