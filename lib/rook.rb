require_relative 'slideable'
require_relative 'piece'

class Rook < Piece
  include Slideable

  def initialize(color:, board:, pos:)
    super

    @symbol = :r
    @move_dirs = [[0, -1], [0, 1], [-1, 0], [1, 0]]
  end
end
