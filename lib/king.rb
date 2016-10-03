require_relative 'steppable'
require_relative 'piece'

class King < Piece
  include Steppable

  def initialize(color:, board:, pos:)
    super

    @symbol = :K
    @move_dirs = [
      [-1, -1], [1, 1], [-1, 1], [1, -1],
      [0, 1], [0, -1], [-1, 0], [1, 0]
    ]
  end
end
