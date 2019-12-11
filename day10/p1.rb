require 'set'

grid = []

width = 0
height = 0

File.open('input.txt').each do |line|
  line.strip!
  splitsville = line.split('')
  width = splitsville.size
  grid.push(*splitsville)
  height += 1
end

def get_at_coord(grid, width, x, y)
  grid[(width * y) + x]
end

def reduce_slopes(slopes)
  reduced = Set.new

  slopes.each do |slope|
    if slope[0] == 0
      reduced << [0, 1] if slope[1] > 0
      reduced << [0, -1] if slope[1] < 0
    elsif slope[1] == 0
      reduced << [1, 0] if slope[0] > 0
      reduced << [-1, 0] if slope[0] < 0
    elsif slope[0].gcd(slope[1]) > 1
      gcd = slope[0].gcd(slope[1])
      x_rs = (slope[0] / gcd)
      y_rs = (slope[1] / gcd)
      reduced << [x_rs, y_rs]
    else
      reduced << slope
    end
  end

  reduced
end

max_asteroids_seen = 0

grid.each_with_index do |sector, i|
  x = i % width
  y = i / width

  next unless sector == '#'

  num_asteroids_seen = 0

  slopes_to_check = Set.new

  0.upto(width - 1) do |i|
    0.upto(height - 1) do |j|
      if i != x || j != y # skip the current asteroid
        slopes_to_check << [i - x, j - y]
      end
    end
  end

  reduced_slopes = reduce_slopes(slopes_to_check)

  reduced_slopes.each do |slope|
    x_s = slope[0]
    y_s = slope[1]
    next if x_s.zero? && y_s.zero?

    x_t = x
    y_t = y

    loop do
      x_t += x_s
      y_t += y_s

      break unless x_t >= 0 && y_t >= 0 && x_t < width && y_t < height

      sector = get_at_coord(grid, width, x_t, y_t)

      if sector == '#'
        num_asteroids_seen += 1
        break
      end
    end
  end

  if num_asteroids_seen > max_asteroids_seen
    max_asteroids_seen = num_asteroids_seen
  end
end

puts max_asteroids_seen
