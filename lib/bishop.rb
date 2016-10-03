require_relative 'slideable'
require_relative 'piece'

class Bishop < Piece
  include Slideable

  def initialize(color:, board:, pos:)
    super

    @symbol = :b
    @move_dirs = [[-1, -1], [1, 1], [-1, 1], [1, -1]]
  end
end
