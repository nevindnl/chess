require_relative "display"

class Player
  attr_reader :color, :display

  def initialize(color:, board:)
    @color = color
		@display = Display.new(board)
  end

  def command
    result = nil

    until result
      @display.render
      puts "It is #{@color}'s turn."
      result = @display.get_input
    end

    result
  end
end
