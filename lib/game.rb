require_relative 'board'
require_relative 'player'
require_relative 'bishop'
require_relative 'rook'
require_relative 'king'
require_relative 'knight'
require_relative 'queen'
require_relative 'pawn'

class Game
  attr_reader :white, :black

  def initialize()
    @board = Board.new
    @board.make_starting_grid

    @white = Player.new(color: :white, board: @board)
    @black = Player.new(color: :black, board: @board)

    @current_player = @white

		@difficulty = {}
  end

  def swap_players
    @current_player = @current_player == @white ? @black : @white
  end

  def loser
    [:white, :black].find { |color| @board.checkmate?(color) }
  end

  def move
    start_pos = @current_player.command
		piece = @board[start_pos]

		if piece == NullPiece.instance
			puts "No piece at start position."
			sleep(1)

			return move
		elsif piece.color != @current_player.color
			puts "Not a valid move."
			sleep(1)

			return move
		end

    end_pos = @current_player.command

		if !piece.valid_move?(end_pos)
			puts "Not a valid move."
			sleep(1)

			move
		else
      @board.move(start_pos, end_pos)
		end
  end

  def computer_move
		@current_player.display.render

		@board.move(*minimax[:move])
		# @board.move(*capture_if_possible)

		sleep(0.3)
  end

	def player_pieces
		@current_player == @white ? @board.white_pieces : @board.black_pieces
	end

	# AI: capture if possible

	def capture_if_possible
		#keys are piece_pos's, values are piece_moves's
		moves = {}

		player_pieces.each do |piece|
			piece_moves = piece.valid_moves

			moves[piece.pos] = piece_moves unless piece_moves.empty?
		end

		other_color = @current_player == @white ? :black : :white

		captures = {}
		moves.each do |piece_pos, piece_moves|

			piece_captures = piece_moves.select do |move|
				@board[move].color == other_color
			end

			captures[piece_pos] = piece_captures unless piece_captures.empty?
		end

		moves = captures unless captures.empty?

		start_pos = moves.keys.sample
		end_pos = moves[start_pos].sample

		[start_pos, end_pos]
	end

	def other_player player = @current_player
		player == @white ? @black : @white
	end

	# AI: minimax with alpha-beta pruning

	# initialize alpha and beta to sentinels
	def minimax player: @current_player, board: @board, move: nil, alpha: -400, beta: 400, depth: 0
		# terminate at max depth or checkmate
		if depth == @difficulty[@current_player.color] || score(board).abs == 300
			return {score: score(board), move: move}
		end

		pieces = player.color == :white ? board.white_pieces : board.black_pieces
		pieces.shuffle!

		best_move = nil

		# max if current_player
		if player == @current_player
			best_score = alpha

			# iterate through possible moves
			pieces.each do |piece|
				piece.valid_moves.each do |end_pos|
					# for each move:
					possible_move = [piece.pos, end_pos]

					# create board
					possible_board = board.dup
					possible_board.move(*possible_move)

					# recurse to find best score after move, updating lower bound
					possible_score = minimax(
						player: other_player(player),
						board: possible_board,
						move: possible_move,
						alpha: best_score,
						beta: beta,
						depth: depth + 1
					)[:score]

					# terminate if score is greater than minimizing player would allow
					if possible_score > beta
						return {score: beta, move: nil}
					end

					# update best score
					if possible_score > best_score
						best_score = possible_score
						best_move = possible_move
					end
				end
			end

		# min if other player
		else
			best_score = beta

			pieces.each do |piece|
				piece.valid_moves.each do |end_pos|
					possible_move = [piece.pos, end_pos]

					possible_board = board.dup
					possible_board.move(*possible_move)

					# recurse to find best score after move, updating upper bound
					possible_score = minimax(
						player: other_player(player),
						board: possible_board,
						move: possible_move,
						alpha: alpha,
						beta: best_score,
						depth: depth + 1
					)[:score]

					# terminate if score is less than maximizing player would allow
					if possible_score < alpha
						return {score: alpha, move: nil}
					end

					if possible_score < best_score
						best_score = possible_score
						best_move = possible_move
					end
				end
			end
		end

		{score: best_score, move: best_move}
	end

	def score board
		board.score(@current_player.color)
	end

	def get_difficulty color
		puts "Enter difficulty (1 = easy, 2, 3 = hard):"
		input = gets.chomp.to_i

		if [1,2,3].include? input
			@difficulty[color] = input
		else
			puts "Not a valid difficulty."
			get_difficulty color
		end
	end

	def run
		system("clear")

		puts "Welcome to Chess."

		sleep(2)

		puts "Enter number of players (0, 1, 2):"
		input = gets.chomp.to_i

		case input
		when 0
			puts "Computer (Black)"
			get_difficulty :black
			puts "Computer (White)"
			get_difficulty :white
			zero_player_run
		when 1
			get_difficulty :black
			one_player_run
		when 2
			two_player_run
		else
			puts "Not a valid number of players."
			sleep(1)

			run
		end
	end

  def zero_player_run
    turns = 0
    until loser
      computer_move
      swap_players

      turns += 1
    end

    @current_player.display.render
    puts "#{loser} loses."

    loser
  end

	def one_player_run
		computer = false
		until loser
			computer ? computer_move : move
			swap_players

			computer = !computer
		end

		@current_player.display.render
		puts "#{loser} loses."
	end

	def two_player_run
		until loser
			move
			swap_players
		end

		@current_player.display.render
		puts "#{loser} loses."
	end
end
