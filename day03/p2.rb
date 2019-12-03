w1_path = []
w2_path = []

Coord = Struct.new(:x, :y, :accum) do
  def ==(other)
    x == other.x && y == other.y
  end

  def hash
    "#{x},#{y}".hash
  end

  alias_method :eql?, :==
end

File.open('input.txt').each_with_index do |line, index|
  if index.zero?
    w1_path = line.split(',')
  else
    w2_path = line.split(',')
  end
end

def path_coords(path)
  curr_x = 0
  curr_y = 0
  accum = 0
  coords = []

  path.each do |segment|
    direction = segment.slice!(0)
    segment = segment.to_i

    case direction
    when 'R'
      # right
      curr_x.upto(curr_x + segment) do |n|
        coords << Coord.new(n, curr_y, accum)
        accum += 1
      end
      curr_x += segment
    when 'L'
      # left
      curr_x.downto(curr_x - segment) do |n|
        coords << Coord.new(n, curr_y, accum)
        accum += 1
      end
      curr_x -= segment
    when 'U'
      # up
      curr_y.upto(curr_y + segment) do |n|
        coords << Coord.new(curr_x, n, accum)
        accum += 1
      end
      curr_y += segment
    when 'D'
      # down
      curr_y.downto(curr_y - segment) do |n|
        coords << Coord.new(curr_x, n, accum)
        accum += 1
      end
      curr_y -= segment
    end

    accum -= 1
  end

  coords
end

w1_coords = path_coords(w1_path)
w2_coords = path_coords(w2_path)

intersections = (w1_coords & w2_coords).select { |i| i.x.nonzero? && i.y.nonzero? }

min_accum = intersections.reduce(0) do |min, i|
  w1 = w1_coords.select { |w| w == i }.first
  w2 = w2_coords.select { |w| w == i }.first
  combined = w1.accum + w2.accum

  min = combined if min.zero? || combined < min
  min
end

puts min_accum
