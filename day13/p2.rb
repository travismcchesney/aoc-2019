input = []
tiles = []
play_game = ARGV[0] == '--play'
show_game = ARGV[0] == '--show'
ARGV.clear

#
# Run with param "--play", to actually play the game!
# Run with param "--show" to see the automated game
#

Tile = Struct.new(:x, :y, :type) do
  def to_s
    "(#{x}, #{y}, #{type})"
  end
end

File.open('input.txt').each do |line|
  input.push(*line.split(',').map(&:to_i))
end

input[0] = 2 # play for free!
input.freeze

def get_arg(prog, mode, curr_i, arg_num, base)
  if mode.zero? # position
    prog[prog[curr_i + arg_num]]
  elsif mode == 1 # immediate
    prog[curr_i + arg_num]
  elsif mode == 2 # relative
    prog[prog[curr_i + arg_num] + base]
  end
end

def write_val(prog, mode, curr_i, arg_num, base, val)
  if mode == 2 # relative
    prog[prog[curr_i + arg_num] + base] = val
  else # immediate
    prog[prog[curr_i + arg_num]] = val
  end
end

def tile_at(tiles, x, y)
  tiles.each do |tile|
    return tile if tile.x == x && tile.y == y
  end
  nil
end

def board_size(tiles)
  width = 0
  height = 0

  tiles.each do |tile|
    width = tile.x if tile.x > width
    height = tile.y if tile.y > height
  end

  [width, height]
end

def update_board(tiles, output, print_score)
  output.each_slice(3) do |slice|
    if slice[0] == -1 && slice[1].zero?
      puts "#{slice[2]}" if print_score
    else
      tile = Tile.new(slice[0], slice[1], slice[2])
      if !tile_at(tiles, tile.x, tile.y)
        tiles << tile
      else
        tile_at(tiles, tile.x, tile.y).type = tile.type
      end
    end
  end
end

def print_board(tiles)
  width, height = board_size(tiles)

  0.upto(height) do |y|
    0.upto(width) do |x|
      tile = tile_at(tiles, x, y)
      if tile
        print '.' if tile.type.zero?
        print '*' if tile.type == 1
        print '#' if tile.type == 2
        print '_' if tile.type == 3
        print 'O' if tile.type == 4
      else
        print ' '
      end
    end
    print "\n"
  end
  print "\n"
end

def get_ball_paddle(tiles)
  paddle = nil
  ball = nil
  tiles.each do |tile|
    ball = tile if tile.type == 4
    paddle = tile if tile.type == 3
  end
  [ball, paddle]
end


def run_program(prog, tiles, i, rel_base, show_game, play_game)
  output = []

  while i < prog.length
    # Get the instruction, which for now we left-pad with 0s since the hundreds
    # and higher place digits correspond to parameter modes, and we don't have
    # any op codes that use more than two input parameters. The instruction is
    # constructed like so:
    #
    #   ABCDE
    #   01002
    #
    #   DE - two-digit opcode,      02 == opcode 2
    #    C - mode of 1st parameter,  0 == position mode
    #    B - mode of 2nd parameter,  1 == immediate mode
    #    A - mode of 3rd parameter,  0 == position mode,
    #                                     omitted due to being a leading zero
    instr = prog[i].to_s.rjust(5, '0')

    # The opcode is the last two digits
    op = instr[-2..-1].to_i
    p1 = instr[-3..-3].to_i
    p2 = instr[-4..-4].to_i
    p3 = instr[-5..-5].to_i

    case op
    when 1 # add
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i + arg2.to_i)
      i += 4
    when 2 # multiply
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i * arg2.to_i)
      i += 4
    when 3 # input
      update_board(tiles, output, show_game || play_game)
      output = []
      ball, paddle = get_ball_paddle(tiles)

      input = nil

      print_board(tiles) if show_game || play_game

      if play_game
        puts 'Direction (stay: 0, left: -1, right: 1):'
        input = gets.chomp
      else
        input = -1 if ball.x < paddle.x
        input = 0 if ball.x == paddle.x
        input = 1 if ball.x > paddle.x
      end

      write_val(prog, p1, i, 1, rel_base, input)
      i += 2
    when 4 # output
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      output << arg1
      i += 2
    when 5 # jump-if-true
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      i = arg1.to_i.zero? ? i + 3 : arg2.to_i
    when 6 # jump-if-false
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      i = arg1.to_i.zero? ? arg2.to_i : i + 3
    when 7 # less than
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i < arg2.to_i ? 1 : 0)
      i += 4
    when 8 # equal
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i == arg2.to_i ? 1 : 0)
      i += 4
    when 9
      arg1 = get_arg(prog, p1, i, 1, rel_base)

      rel_base += arg1
      i += 2
    when 99 # donezo
      update_board(tiles, output, true)
      return nil
    end
  end

  prog
end


prog = input.map(&:clone)


i = 0
rel_base = 0

loop do
  output, i, rel_base = run_program(prog, tiles, i, rel_base, show_game, play_game)

  break if output.nil?
end
