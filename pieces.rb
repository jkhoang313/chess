def check_moves(piece_name, column, row, occupied, enemy_occupied, side, pawn_first_move=false, pawn_double_move=false)
#straight movesfor rook/queen
	up_moves = [[0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7]]
	down_moves = [[0,+1],[0,+2],[0,+3],[0,+4],[0,+5],[0,+6],[0,+7]]
	left_moves = [[-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0]]
	right_moves = [[+1,0],[+2,0],[+3,0],[+4,0],[+5,0],[+6,0],[+7,0]]
#diagonal moves for bishop/queen
	up_right_moves = [[+1,-1],[+2,-2],[+3,-3],[+4,-4],[+5,-5],[+6,-6],[+7,-7]]
	down_right_moves = [[+1,+1],[+2,+2],[+3,+3],[+4,+4],[+5,+5],[+6,+6],[+7,+7]]
	down_left_moves = [[-1,+1],[-2,+2],[-3,+3],[-4,+4],[-5,+5],[-6,+6],[-7,+7]]
	up_left_moves = [[-1,-1],[-2,-2],[-3,-3],[-4,-4],[-5,-5],[-6,-6],[-7,-7]]

	case piece_name
	when "King" 
		changes = [[-1,0],[-1,-1],[0,-1],[+1,-1],[+1,0],[+1,+1],[0,+1],[-1,+1]]
		poss_moves(changes, column, row, occupied, enemy_occupied, false)
	when "Queen"
		changes = up_moves, down_moves, left_moves, right_moves, up_right_moves, down_right_moves, down_left_moves, up_left_moves
		poss_moves(changes, column, row, occupied, enemy_occupied, true)
	when "Rook"
		changes = up_moves, down_moves, left_moves, right_moves
		poss_moves(changes, column, row, occupied, enemy_occupied, true)
	when "Bishop"
		changes = up_right_moves, down_right_moves, down_left_moves, up_left_moves
		poss_moves(changes, column, row, occupied, enemy_occupied, true)
	when "Knight"
		changes = [[-2,-1],[-2,1],[-1,-2],[-1,2],[2,-1],[2,1],[1,-2],[1,2]]
		poss_moves(changes, column, row, occupied, enemy_occupied, false)
	when "Pawn"
		moves = []
		changes = []
		if side == "Black "
			pawn_capture = [[-1,+1],[+1,+1]]	
			pawn_capture.each do |movement| 
				capture_move = [column+movement[0],row+movement[1]]	
				moves << capture_move if enemy_occupied.include?(capture_move)
			end
		else
			pawn_capture = [[-1,-1],[+1,-1]]
			pawn_capture.each do |movement| 
				capture_move = [column+movement[0],row+movement[1]]	
				moves << capture_move if enemy_occupied.include?(capture_move)
			end
		end

		if pawn_double_move == true
			return moves
		elsif side == "Black "
			pawn_first_move == true ? changes += [[0,+1]] : changes += [[0,+1],[0,+2]]
			moves += poss_pawn_moves(changes, column, row, occupied, enemy_occupied)
		else
			pawn_first_move == true ? changes += [[0,-1]] : changes += [[0,-1],[0,-2]]
			moves += poss_pawn_moves(changes, column, row, occupied, enemy_occupied)
		end
		moves
	end
end


def poss_moves(changes, column, row, occupied, enemy_occupied, blockable)
		moves = []
		if blockable == false
			changes.each do |change| 
				current_move = [column+change[0], row+change[1]]
				moves << current_move if !occupied.include?(current_move)
			end
		elsif blockable == true
			changes.each do |direction|
				direction.each do |change|
					current_move = [column+change[0], row+change[1]]
					break if occupied.include?(current_move)
					moves << current_move
					break if enemy_occupied.include?(current_move)
				end
			end
		end
		moves.select {|move| valid_position?(move)}
end


def poss_pawn_moves(changes, column, row, occupied, enemy_occupied)
	moves = []
	changes.each do |change|
		current_move = [column+change[0], row+change[1]]
		break if occupied.include?(current_move)
		break if enemy_occupied.include?(current_move)
		moves << current_move
	end
		moves.select {|move| valid_position?(move)}
end


def valid_position?(pos)
	return (pos[0] > 0 && pos[0] < 9) && (pos[1] > 0 && pos[1] < 9) ? true : false
end
