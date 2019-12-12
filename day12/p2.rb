$stdout.sync = true

positions = {}

Triple = Struct.new(:x, :y, :z) do
  def to_s
    "(#{x}, #{y}, #{z})"
  end
end

File.open('input.txt').each do |line|
  x, y, z = line.match(/^\<x=(.+), y=(.+), z=(.+)\>$/).captures
  triple = Triple.new(x.to_i, y.to_i, z.to_i)
  positions[triple] = Triple.new(0, 0, 0)
end

i = 0
init_x_state = ''
init_y_state = ''
init_z_state = ''
x_repeated = nil
y_repeated = nil
z_repeated = nil

loop do
  # apply gravity
  positions.each_pair do |moon, velocity|
    positions.each_key do |peer|
      next if moon == peer

      velocity.x += moon.x == peer.x ? 0 : moon.x < peer.x ? 1 : -1
      velocity.y += moon.y == peer.y ? 0 : moon.y < peer.y ? 1 : -1
      velocity.z += moon.z == peer.z ? 0 : moon.z < peer.z ? 1 : -1
    end
  end

  # update velocities
  positions.each_pair do |moon, velocity|
    moon.x += velocity.x
    moon.y += velocity.y
    moon.z += velocity.z
  end

  set_x_rep = ''
  set_y_rep = ''
  set_z_rep = ''

  positions.each_pair do |moon, velocity|
    set_x_rep += "#{moon.x},#{velocity.x}"
    set_y_rep += "#{moon.y},#{velocity.y}"
    set_z_rep += "#{moon.z},#{velocity.z}"
  end

  if i == 0
    init_x_state = set_x_rep.hash
    init_y_state = set_y_rep.hash
    init_z_state = set_z_rep.hash
  elsif set_x_rep.hash == init_x_state && !x_repeated
    x_repeated = i
  elsif set_y_rep.hash == init_y_state && !y_repeated
    y_repeated = i
  elsif set_z_rep.hash == init_z_state && !z_repeated
    z_repeated = i
  end

  if x_repeated && y_repeated && z_repeated
    puts x_repeated.lcm(y_repeated).lcm(z_repeated)
    break
  end

  i += 1
end
