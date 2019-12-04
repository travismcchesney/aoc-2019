lower = nil
upper = nil

File.open('input.txt').each do |line|
  lower, upper = line.split('-')
end

lower = lower.to_i
upper = upper.to_i

def valid?(password, upper)
  parts = password.to_s.split('')

  return false if password > upper

  increasing = parts[0] <= parts[1] &&
               parts[1] <= parts[2] &&
               parts[2] <= parts[3] &&
               parts[3] <= parts[4] &&
               parts[4] <= parts[5]
  return false unless increasing

  has_double = parts[0] == parts[1] ||
               parts[1] == parts[2] ||
               parts[2] == parts[3] ||
               parts[3] == parts[4] ||
               parts[4] == parts[5]
  return false unless has_double

  prev = ''
  occur = {}
  parts.each do |part|
    next if occur[part] == -1
    occur[part] = prev == part ? occur[part] + 1 : 1

    occur[part] = -1 if occur[part] > 2
    prev = part
  end

  return false unless occur.value?(2)

  true
end

valid = 0

lower.upto(upper) do |num|
  is_valid = valid?(num, upper)
  valid += 1 if is_valid
end

puts valid
