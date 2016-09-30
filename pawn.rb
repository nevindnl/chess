require './steppable'
require './piece'

class Pawn < Piece
  attr_reader :symbol, :move_dirs, :color

  def initialize(color, board, pos)
    super

    @symbol = :p

    if @color == :white
      @move_dirs = [[-1,0]]
      @attack_move_dirs = [[-1, -1], [-1, 1]]
    else
      @move_dirs = [[1,0]]
      @attack_move_dirs = [[1, -1], [1, 1]]
    end

    @initial_pos = pos
  end

  def at_start_row?
    @pos == @initial_pos
  end

  def moves
    row, col = @pos
    all_moves = []

    @move_dirs.each do |move_dir|
      delta_row, delta_col = move_dir

      (1..2).each do |dist|
        break if dist == 2 && !at_start_row?

        new_row = row + delta_row * dist
        new_col = col + delta_col * dist

        break unless @board.in_bounds?([new_row, new_col]) &&
          @board[[new_row, new_col]] == NullPiece.instance

        all_moves << [new_row, new_col]
      end
    end

    @attack_move_dirs.each do |move_dir|
      delta_row, delta_col = move_dir

      new_row = row + delta_row
      new_col = col + delta_col

      #next if piece is our color or out of bounds
      next unless @board.in_bounds?([new_row, new_col]) &&
        @board[[new_row, new_col]].color == @opponent_color

      all_moves << [new_row, new_col]
    end

    all_moves
  end

end
