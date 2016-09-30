require './nullpiece'

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
    self[[7,0]] = Rook.new(:white, self, [7,0])
    self[[7,1]] = Knight.new(:white, self, [7,1])
    self[[7,2]] = Bishop.new(:white, self, [7,2])
    self[[7,3]] = Queen.new(:white, self, [7,3])
    self[[7,4]] = King.new(:white, self, [7,4])
    self[[7,5]] = Bishop.new(:white, self, [7,5])
    self[[7,6]] = Knight.new(:white, self, [7,6])
    self[[7,7]] = Rook.new(:white, self, [7,7])

    (0..7).each do |col|
      self[[0, col]] = self[[7, col]].class.new(:black, self, [0, col])
    end

    #make pawns
    (0..7).each { |col| self[[6, col]] = Pawn.new(:white, self, [6, col])}
    (0..7).each { |col| self[[1, col]] = Pawn.new(:black, self, [1, col])}

    collect_armies
  end

  def collect_armies
    @white_pieces = @rows.flatten.select{ |piece| piece.color == :white }
    @black_pieces = @rows.flatten.select{ |piece| piece.color == :black }
  end

  def move(start_pos, end_pos)
    piece = self[start_pos]

    raise "No piece at start position." if piece == NullPiece.instance
    raise "Not a valid move." unless piece.valid_move?(end_pos)

    #update piece's position
    piece.pos = end_pos

    #update board
    self[end_pos] = self[start_pos]
    self[start_pos] = NullPiece.instance

    collect_armies
  end

  def in_bounds?(pos)
    row, col = pos
    row.between?(0, 7) && col.between?(0, 7)
  end

  def find_king(color)
    pieces = @black_pieces + @white_pieces

    king = pieces.find { |piece| piece.color == color && piece.symbol == :K }
    king.pos
  end

  def in_check?(color)
    king_pos = find_king(color)

    opponent_piece_array = color == :white ? @black_pieces : @white_pieces
    opponent_piece_array.any? { |piece| piece.moves.include?(king_pos) }
  end

  def dup
    new_board = Board.new
    pieces = @black_pieces + @white_pieces

    pieces.each do |piece|
      pos = piece.pos
      color = piece.color

      new_board[pos] = piece.class.new(color, new_board, pos)
    end

    new_board.collect_armies
    new_board
  end

  def checkmate?(color)
    player_pieces = color == :white ? @white_pieces : @black_pieces
    player_pieces.all? { |piece| piece.valid_moves.empty? }
  end

  #for testing
  def render
    @rows.each { |row| puts row.map(&:to_s).join("|") }
  end
end
