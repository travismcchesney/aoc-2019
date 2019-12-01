def get_fuel(tot, mass)
  fuel = (mass.to_i / 3) - 2

  if fuel <= 0
    return 0
  end

  return fuel + get_fuel(tot, fuel)
end

sum = 0

File.open('input.txt').each do |mass|
  sum += get_fuel(0, mass)
end

puts sum

