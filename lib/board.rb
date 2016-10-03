require_relative 'nullpiece'

class Board
  attr_reader :rows, :white_pieces, :black_pieces

  def initialize
    @rows = Array.new(8) { Array.new(8) { NullPiece.instance } }
  end

  def [](pos)
    row, col = pos
    @rows[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @rows[row][col] = value
  end

  def make_starting_grid
    #make non-pawns
    self[[7,0]] = Rook.new(color: :white, board: self, pos: [7,0])
    self[[7,1]] = Knight.new(color: :white, board: self, pos: [7,1])
    self[[7,2]] = Bishop.new(color: :white, board: self, pos: [7,2])
    self[[7,3]] = Queen.new(color: :white, board: self, pos: [7,3])
    self[[7,4]] = King.new(color: :white, board: self, pos: [7,4])
    self[[7,5]] = Bishop.new(color: :white, board: self, pos: [7,5])
    self[[7,6]] = Knight.new(color: :white, board: self, pos: [7,6])
    self[[7,7]] = Rook.new(color: :white, board: self, pos: [7,7])

    (0..7).each do |col|
      self[[0, col]] = self[[7, col]].class.new(color: :black, board: self, pos: [0, col])
    end

    #make pawns
    (0..7).each { |col| self[[6, col]] = Pawn.new(color: :white, board: self, pos: [6, col])}
    (0..7).each { |col| self[[1, col]] = Pawn.new(color: :black, board: self, pos: [1, col])}

    collect_armies
  end

  def collect_armies
    @white_pieces = @rows.flatten.select{ |piece| piece.color == :white }
    @black_pieces = @rows.flatten.select{ |piece| piece.color == :black }
  end

	def pieces(color)
		color == :white ? @white_pieces : @black_pieces
	end

	def find_king(color)
		king = pieces(color).find { |piece| piece.symbol == :K }
		king.pos
	end

  def move(start_pos, end_pos)
    piece = self[start_pos]
    piece.pos = end_pos

		#pawn promotion
		if piece.is_a?(Pawn) && piece.at_end_row?
			piece = Queen.new(color: piece.color, board: piece.board, pos: piece.pos)
		end

    #update board
    self[end_pos] = piece
    self[start_pos] = NullPiece.instance

    collect_armies
  end

  def in_bounds?(pos)
    row, col = pos
    row.between?(0, 7) && col.between?(0, 7)
  end

  def in_check?(color)
    king_pos = find_king(color)

    opponent_pieces = color == :white ? @black_pieces : @white_pieces
    opponent_pieces.any? { |piece| piece.moves.include?(king_pos) }
  end

  def checkmate?(color)
    pieces(color).all? { |piece| piece.valid_moves.empty? }
  end

	def score color
		other_color = color == :white ? :black : :white

		if checkmate? color
			-300
		elsif checkmate? other_color
			300
		else
			check =
				if in_check? color
					-10
				elsif in_check? other_color
					10
				else
					0
				end

			piece_sum(color) - piece_sum(other_color) + check
		end
	end

	def piece_sum color
		pieces(color).inject(0) do |score, piece|
			if piece.is_a? Pawn
				score + 1
			elsif piece.is_a? Knight
				score + 4
			elsif piece.is_a? Bishop
				score + 12
			elsif piece.is_a? Rook
				score + 15
			elsif piece.is_a? Queen
				score + 20
			else
				score
			end
		end
	end

	def dup
		new_board = Board.new
		pieces = @black_pieces + @white_pieces

		pieces.each do |piece|
			pos = piece.pos
			color = piece.color

			new_board[pos] = piece.class.new(color: color, board: new_board, pos: pos)
		end

		new_board.collect_armies
		new_board
	end

  #for testing
  def render
    @rows.each { |row| puts row.map(&:to_s).join("|") }
  end
end
