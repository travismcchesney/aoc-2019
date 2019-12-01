sum = 0

File.open('input.txt').each do |mass|
  fuel = (mass.to_i / 3) - 2
  sum += fuel
end

puts sum
