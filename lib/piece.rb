class Piece
  attr_accessor :board, :pos
	attr_reader :color, :symbol, :move_dirs

  SYMBOLS = {
    p: {white: "\u2659" , black: "\u265f"},
    r: {white: "\u2656" , black: "\u265c"},
    b: {white: "\u2657" , black: "\u265d"},
    k: {white: "\u2658" , black: "\u265e"},
    q: {white: "\u2655" , black: "\u265b"},
    K: {white: "\u2654" , black: "\u265a"},
  }

  def initialize(color:, board:, pos:)
    @color = color
    @board = board
    @pos = pos

    @opponent_color = @color == :white ? :black : :white
  end

  def move_into_check?(end_pos)
    temp_board = @board.dup
    temp_board.move(@pos, end_pos)

    temp_board.in_check?(@color)
  end

  def valid_moves
    moves.reject { |move| move_into_check?(move) }
  end

  def valid_move?(end_pos)
    valid_moves.include?(end_pos)
  end

  def to_s
    " #{SYMBOLS[@symbol][@color].encode('utf-8')} "
  end
end
