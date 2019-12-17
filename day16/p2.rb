PHASES = 100

input = []

File.open('input.txt').each do |line|
  input.push(*line.strip.split('').map(&:to_i))
end

offset = input[0, 7].join('').to_i
exit if offset < input.size / 2 # can't handle offsets less than half the input size
input *= 10_000 # duplicate input 10,000 times
input = input.slice(offset, input.size - 1) # just take the bit from the offset to the end

PHASES.times do |p|
  p += 1

  input.size.times do |n|
    n += 1
    n *= -1

    next if n == -1

    sum = input[n] + input[n + 1]
    input[n] = sum
  end
  input = input.map { |o| o % 10 }
  puts input.take(8).join('') if p == PHASES
end

