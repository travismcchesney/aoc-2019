def get_fuel(mass)
  fuel = (mass.to_i / 3) - 2

  if fuel <= 0
    return 0
  end

  return fuel + get_fuel(fuel)
end

sum = 0

File.open('input.txt').each do |mass|
  sum += get_fuel(mass)
end

puts sum

