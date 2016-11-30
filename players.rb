class Player
	attr_accessor :pieces, :name, :king_checked, :check
	attr_reader :side, :occupied, :king_position, :total_possible_moves, :capture, :player, :new_piece_pos

	def initialize(player)
		if player == 1
			@side = "Black "
			@pieces = [["Rook",1,1],["Knight",2,1],["Bishop",3,1],["Queen",4,1],["King",5,1],["Bishop",6,1],["Knight",7,1],["Rook",8,1],["Pawn",1,2,false,false],["Pawn",2,2,false,false],["Pawn",3,2,false,false],["Pawn",4,2,false,false],["Pawn",5,2,false,false],["Pawn",6,2,false,false],["Pawn",7,2,false,false],["Pawn",8,2,false,false]]
#[piecename, piecerow, piececolumn, madefirstmove?(pawn), madedoublemove?(pawn)]
		else
			@side = "White "
			@pieces = [["Pawn",1,7,false,false],["Pawn",2,7,false,false],["Pawn",3,7,false,false],["Pawn",4,7,false,false],["Pawn",5,7,false,false],["Pawn",6,7,false,false],["Pawn",7,7,false,false],["Pawn",8,7,false,false],["Rook",1,8],["Knight",2,8],["Bishop",3,8],["Queen",4,8],["King",5,8],["Bishop",6,8],["Knight",7,8],["Rook",8,8]]
		end
		update_pieces
	end


	def update_pieces
		@occupied = []
		@pieces.each {|piece| @occupied << [piece[1],piece[2]]}
		@pieces.each {|piece| @king_position = piece[1..2] if piece[0] == "King"}
	end


	def possible_moves(enemy_occupied)
		@total_possible_moves = []
		@pieces.each do |piece_description|
			if piece_description[4].nil?
				@total_possible_moves += check_moves(piece_description[0], piece_description[1], piece_description[2], @occupied, enemy_occupied, @side)
			else
				@total_possible_moves += check_moves(piece_description[0], piece_description[1], piece_description[2], @occupied, enemy_occupied, @side, piece_description[3], piece_description[4])
			end
		end
	end

	def display_moves
		@pieces.each_with_index do |piece_description, number|
			piece = piece_description[0]
			column = piece_description[1]
			row = piece_description[2]
			puts "#{number+1}. #{piece} at (#{column}, #{row})"
		end
	end


	def choose_piece
#lists each piece with its position
		puts "\n"
		puts "#{@name}, which piece do you want you move? (Choose the number of the piece)"
		@figure = gets.chomp.to_i
		until @figure > 0 && @figure <= @pieces.length
			puts "Please enter a valid choice."
			@figure = gets.chomp.to_i
		end
		@chosen_piece_index = @figure-1
		@chosen_piece = @pieces[@chosen_piece_index][0]
		@chosen_piece_column = @pieces[@chosen_piece_index][1]
		@chosen_piece_row = @pieces[@chosen_piece_index][2]
	end

	def choose_move(enemy_occupied)
#lists possible moves
		moves = []
		if @chosen_piece == "Pawn"
			moves = check_moves(@chosen_piece, @chosen_piece_column, @chosen_piece_row, @occupied, enemy_occupied, @side, @pieces[@chosen_piece_index][3], @pieces[@chosen_piece_index][4])
#adds madefirstmove? and madedoublemove?
		else
			moves = check_moves(@chosen_piece, @chosen_piece_column, @chosen_piece_row, @occupied, enemy_occupied, @side)
		end

		if moves.empty?
			puts "There are no possible moves for the #{@chosen_piece} at (#{@chosen_piece_column}, #{@chosen_piece_row})."
			choose_piece
			choose_move(enemy_occupied)
		else
			puts "Where would you like to move the #{@chosen_piece} at (#{@chosen_piece_column}, #{@chosen_piece_row}) to? (Type 0 to go back)"
			moves.each_with_index {|move, number| puts "#{number+1}. (#{move[0]}, #{move[1]})"}
			@move = gets.chomp.to_i
			until @move >= 0 && @move <= moves.length
				puts "Please enter a valid choice."
				@move = gets.chomp.to_i
			end

			if @move == 0
				choose_piece
				choose_move(enemy_occupied)
			else
				@new_piece_pos = moves[@move-1]
			end
		end
	end


	def make_move(enemy_occupied)
		if @chosen_piece == "Pawn"
				@pieces[@chosen_piece_index][3] = true
				@pieces[@chosen_piece_index][4] = true if @new_piece_pos[1]-@chosen_piece_row == 2 || @new_piece_pos[1]-@chosen_piece_row == -2
				[[-1,-1],[+1,-1],[-1,+1],[+1,+1]].each do |movement|
					capture_move = [@chosen_piece_column+movement[0],@chosen_piece_row+movement[1]]
					@pieces[@chosen_piece_index][4] = false if capture_move == @new_piece_pos
				end
		end

		puts "#{@chosen_piece} moved to (#{@new_piece_pos[0]}, #{@new_piece_pos[1]})."
		if enemy_occupied.include?(@new_piece_pos)
			@capture = true
		else
			@capture = false
		end
		@pieces[@chosen_piece_index][1] = @new_piece_pos[0]
		@pieces[@chosen_piece_index][2] = @new_piece_pos[1]
	end


	def declare_check(enemy_occupied, enemy_king)
		possible_moves(enemy_occupied)
		if @total_possible_moves.include?(enemy_king)
			@check = true
			puts "Check!"
		end
	end


	def uncheck_king?(occupied, king_position, enemy_pieces, enemy_occupied, enemy_side)
		king_position = @new_piece_pos if @chosen_piece == "King"
		occupied[@chosen_piece_index] = @new_piece_pos

		if enemy_occupied.include?(@new_piece_pos)
			enemy_occupied.each_with_index do |piece, index|
				if piece[0] == @new_piece_pos[0] && piece[1] == @new_piece_pos[1]
					enemy_pieces.delete_at(index)
					enemy_occupied.delete_at(index)
				end
			end
		end

		enemy_total_moves = []
		enemy_pieces.each do |piece_description|
			if piece_description[4].nil?
				enemy_total_moves += check_moves(piece_description[0], piece_description[1], piece_description[2], enemy_occupied, occupied, enemy_side)
			else
				enemy_total_moves += check_moves(piece_description[0], piece_description[1], piece_description[2], enemy_occupied, occupied, enemy_side, piece_description[3], piece_description[4])
			end
		end

		@king_checked = false if !enemy_total_moves.include?(king_position)
	end

	def checkmate?(enemy_pieces, enemy_occupied, enemy_side, enemy_king, player_pieces, occupied, side)
		@enemy_king = enemy_king
		@declare_check = true
		enemy_pieces.each_with_index do |piece_description, index|
			enemy_moves_for_piece = []
			if piece_description[4].nil?
				enemy_moves_for_piece = check_moves(piece_description[0], piece_description[1], piece_description[2], enemy_occupied, occupied, enemy_side)
			else
				enemy_moves_for_piece = check_moves(piece_description[0], piece_description[1], piece_description[2], enemy_occupied, occupied, enemy_side, piece_description[3], piece_description[4])
			end

			enemy_moves_for_piece.each do |move|
				e_occupied = enemy_occupied
				former = e_occupied[index]
				e_occupied[index] = move
				@enemy_king = move if enemy_pieces[index][0] == "King"

				player_total_moves = []
				player_pieces.each do |piece|
					if piece_description[4].nil?
						player_total_moves += check_moves(piece[0], piece[1], piece[2], occupied, e_occupied, side)
					else
						player_total_moves += check_moves(piece[0], piece[1], piece[2], occupied, e_occupied, side, piece[3], piece[4])
					end
				end
				@declare_check = false if !player_total_moves.include?(@enemy_king)
				e_occupied[index] = former
			end
		end
		@declare_check
	end
end
