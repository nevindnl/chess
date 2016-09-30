module Steppable

  def moves
    row, col = @pos
    all_moves = []

    @move_dirs.each do |move_dir|
      delta_row, delta_col = move_dir

      new_row = row + delta_row
      new_col = col + delta_col

      #next if piece is our color or out of bounds
      next unless @board.in_bounds?([new_row, new_col]) &&
        @board[[new_row, new_col]].color != @color

      all_moves << [new_row, new_col]
    end

    all_moves
  end
end
