input = []
tiles = []
print_map = ARGV[0] == '--print-map'
ARGV.clear

#
# Run with param "--print-map", to show the full map!
# Run with no param to just get the final number of minutes
#
Tile = Struct.new(:x, :y, :type) do
  def to_s
    "(#{x}, #{y}, #{type})"
  end
end

File.open('input.txt').each do |line|
  input.push(*line.split(',').map(&:to_i))
end

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

def tiles_of_type(tiles, type)
  tiles.select do |tile|
    tile.type == type
  end
end

def adjacent_tiles(tiles, tile)
  [tile_at(tiles, tile.x - 1, tile.y),
   tile_at(tiles, tile.x + 1, tile.y),
   tile_at(tiles, tile.x, tile.y - 1),
   tile_at(tiles, tile.x, tile.y + 1)]
end

def board_size(tiles)
  min_x = 0
  max_x = 0
  min_y = 0
  max_y = 0

  tiles.each do |tile|
    min_x = tile.x if tile.x < min_x
    max_x = tile.x if tile.x > max_x
    min_y = tile.y if tile.y < min_y
    max_y = tile.y if tile.y > max_y
  end

  [min_x, max_x, min_y, max_y]
end

def print_board(tiles)
  min_x, max_x, min_y, max_y = board_size(tiles)
  min_y.upto(max_y) do |y|
    min_x.upto(max_x) do |x|
      tile = tile_at(tiles, x, y)
      if tile
        print tile.type
      else
        print ' '
      end
    end
    print "\n"
  end
  print "\n"
end

def run_program(prog, i, rel_base, direction)
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
      input = direction

      write_val(prog, p1, i, 1, rel_base, input)
      i += 2
    when 4 # output
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      i += 2
      return arg1, i, rel_base
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
      return nil
    end
  end

  prog
end

prog = input.map(&:clone)

i = 0
rel_base = 0
tried = {}

def search_from(prog, tiles, x, y, dir, i, rel_base, tried)
  return false if tried[[x, y]] == :tried

  output, i, rel_base = run_program(prog, i, rel_base, dir) if dir > 0
  case output
  when 0 # a wall!
    tile = Tile.new(x, y, '#')
    tiles << tile
    return false
  when 1 # a way forward!
    tile = tile_at(tiles, x, y) || Tile.new(x, y, 'D')
    tile.type = '.'
    tiles << tile
    return true if x.zero? && y.zero? # done when we get back to the beginning
  when 2 # oxygen!
    tile = tile_at(tiles, x, y) || Tile.new(x, y, 'D')
    tile.type = 'O'
    tiles << tile
    tried[[x, y]] = :part_of_path
  when nil
    tiles << Tile.new(x, y, 'S')
  end

  tried[[x, y]] = :tried

  found = search_from(prog, tiles, x - 1, y, 3, i, rel_base, tried) || # west
      search_from(prog, tiles, x + 1, y, 4, i, rel_base, tried) || # east
      search_from(prog, tiles, x, y - 1, 1, i, rel_base, tried) || # north
      search_from(prog, tiles, x, y + 1, 2, i, rel_base, tried) # south

  if found
    tried[[x, y]] = :part_of_path
  else
    tried[[x, y]] = :dead_end
    # back track the opposite direction
    run_program(prog, i, rel_base, dir == 3 ? 4 : dir == 4 ? 3 : dir == 1 ? 2 : 1)
  end

  found
end

def expand(tiles, tile, minute, max_minute)
  tile.type = 'O'
  adjacent_open_tiles = tiles_of_type(adjacent_tiles(tiles, tile), '.')

  return minute if adjacent_open_tiles.empty? # base case

  minute += 1

  adjacent_open_tiles.each do |tile|
    at_minute = expand(tiles, tile, minute, max_minute)
    max_minute = at_minute if at_minute > max_minute
  end

  max_minute
end

search_from(prog, tiles, 0, 0, 0, i, rel_base, tried) # explore entire map

print_board(tiles) if print_map

puts expand(tiles, tiles_of_type(tiles, 'O').first, 0, 0)


