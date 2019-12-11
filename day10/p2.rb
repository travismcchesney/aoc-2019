require 'set'

# Set these to the coordinates of the best asteroid location for your input
X = 20
Y = 20

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

def set_at_coord(grid, width, x, y, val)
  grid[(width * y) + x] = val
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

def sort_slopes(slopes)
  sorted_slopes = []
  sorted_slopes << slopes.sort_by do |s|
    s[1].zero? ? 10000 : (s[0].to_f / s[1])
  end.reverse
  sorted_slopes.flatten!(1)
end

max_asteroids_seen = 0
num_asteroids_seen = 0

while grid.count('#') > 1
  grid.each_with_index do |sector, i|
    x = i % width
    y = i / width

    next unless x == 20 && y == 20
    next unless sector == '#'

    slopes_to_check = Set.new

    0.upto(width - 1) do |i|
      0.upto(height - 1) do |j|
        if i != x || j != y # skip the current asteroid
          slopes_to_check << [i - x, j - y]
        end
      end
    end

    reduced_slopes = reduce_slopes(slopes_to_check)

    slopes_arr = reduced_slopes.to_a
    ur_slopes = slopes_arr.select {|s| s[0] >= 0 && s[1] < 0}
    lr_slopes = slopes_arr.select {|s| s[0] >= 0 && s[1] >= 0}
    ll_slopes = slopes_arr.select {|s| s[0] < 0 && s[1] > 0}
    ul_slopes = slopes_arr.select {|s| s[0] < 0 && s[1] <= 0}

    # upper right quadrant
    sorted_ur_slopes = sort_slopes(ur_slopes)

    # lower right quadrant
    sorted_lr_slopes = sort_slopes(lr_slopes)

    # lower left quadrant
    sorted_ll_slopes = sort_slopes(ll_slopes)

    # upper left quadrant
    sorted_ul_slopes = sort_slopes(ul_slopes)

    sorted_slopes = sorted_ur_slopes + sorted_lr_slopes + sorted_ll_slopes + sorted_ul_slopes
    sorted_slopes.each do |slope|
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
          puts "#{x_t * 100 + y_t}" if num_asteroids_seen == 200
          set_at_coord(grid, width, x_t, y_t, '.') # vaporize that mofo
          break
        end
      end
    end

    if num_asteroids_seen > max_asteroids_seen
      max_asteroids_seen = num_asteroids_seen
    end
  end
end
