pairs = {}

File.open('input.txt').each do |line|
  orbitee, orbiter = line.split(')').map(&:strip)
  pairs[orbiter] = orbitee
end

def orbits(pairs, orbiter)
  orbits = []
  orbitee = nil
  while orbitee != 'COM'
    orbitee = pairs[orbiter]
    orbiter = orbitee
    orbits.push(orbitee)
  end
  orbits
end

you_orbits = orbits(pairs, 'YOU')
san_orbits = orbits(pairs, 'SAN')

you_orbits.each_with_index do |orbit, index|
  if san_orbits.include?(orbit)
    puts index + san_orbits.index(orbit)
    break
  end
end
