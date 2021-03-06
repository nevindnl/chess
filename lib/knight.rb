require_relative 'steppable'
require_relative 'piece'

class Knight < Piece
  include Steppable

  def initialize(color:, board:, pos:)
    super

    @symbol = :k
    @move_dirs = [
      [1, 2], [1, -2], [2, 1], [2, -1],
      [-1, -2], [-1, 2], [-2, 1], [-2, -1]
    ]
  end
end
