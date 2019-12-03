w1_path = []
w2_path = []

Coord = Struct.new(:x, :y)

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
  coords = []

  path.each do |segment|
    direction = segment.slice!(0)
    segment = segment.to_i

    case direction
    when 'R'
      # right
      curr_x.upto(curr_x + segment) do |n|
        coords << Coord.new(n, curr_y)
      end
      curr_x += segment
    when 'L'
      # left
      curr_x.downto(curr_x - segment) do |n|
        coords << Coord.new(n, curr_y)
      end
      curr_x -= segment
    when 'U'
      # up
      curr_y.upto(curr_y + segment) do |n|
        coords << Coord.new(curr_x, n)
      end
      curr_y += segment
    when 'D'
      # down
      curr_y.downto(curr_y - segment) do |n|
        coords << Coord.new(curr_x, n)
      end
      curr_y -= segment
    end
  end

  coords
end

w1_coords = path_coords(w1_path)
w2_coords = path_coords(w2_path)

intersections = (w1_coords & w2_coords).select { |i| i.x.nonzero? && i.y.nonzero? }

min_dist = intersections.reduce(0) do |min, intersection|
  man_dist = intersection.x.abs + intersection.y.abs
  min = man_dist if min.zero? || man_dist < min

  min
end

puts min_dist
