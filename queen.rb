require './slideable'
require './piece'

class Queen < Piece
  include Slideable

  attr_reader :symbol, :move_dirs, :color

  def initialize(color, board, pos)
    super

    @symbol = :q
    @move_dirs = [
      [0, -1], [0, 1], [-1, 0], [1, 0],
      [-1, -1], [1, 1], [-1, 1], [1, -1]
    ]
  end
end
