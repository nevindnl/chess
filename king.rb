require './steppable'
require './piece'

class King < Piece
  include Steppable

  attr_reader :symbol, :move_dirs, :color

  def initialize(color, board, pos)
    super

    @symbol = :K
    @move_dirs = [
      [-1, -1], [1, 1], [-1, 1], [1, -1],
      [0, 1], [0, -1], [-1, 0], [1, 0]
    ]
  end
end
