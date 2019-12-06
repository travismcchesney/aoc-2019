pairs = {}

File.open('input.txt').each do |line|
  orbitee, orbiter = line.split(')').map(&:strip)
  pairs[orbiter] = orbitee
end

orbits = 0

pairs.each_key do |orbiter|
  orbitee = nil
  while orbitee != 'COM'
    orbitee = pairs[orbiter]
    orbiter = orbitee
    orbits += 1
  end
end

puts orbits
