require_relative 'slideable'
require_relative 'piece'

class Rook < Piece
  include Slideable
	attr_accessor :unmoved

  def initialize(color:, board:, pos:)
    super

    @symbol = :r
    @move_dirs = [[0, -1], [0, 1], [-1, 0], [1, 0]]

		@unmoved = true
  end
end
