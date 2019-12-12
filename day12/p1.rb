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

1000.times do |i|
  i += 1
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

  total_energy = 0

  next unless i == 1000

  positions.each_pair do |moon, velocity|
    pot_energy = moon.x.abs + moon.y.abs + moon.z.abs
    kin_energy = velocity.x.abs + velocity.y.abs + velocity.z.abs

    total_energy += pot_energy * kin_energy
  end

  puts total_energy
end
