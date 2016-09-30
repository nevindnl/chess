require './steppable'
require './piece'

class Knight < Piece
  include Steppable

  attr_reader :symbol, :move_dirs, :color

  def initialize(color, board, pos)
    super

    @symbol = :k
    @move_dirs = [
      [1, 2], [1, -2], [2, 1], [2, -1],
      [-1, -2], [-1, 2], [-2, 1], [-2, -1]
    ]
  end
end
