input = []

BASE_PATTERN = [0, 1, 0, -1].freeze
PHASES = 100

File.open('input.txt').each do |line|
  input.push(*line.strip.split('').map(&:to_i))
end

def pattern_for_index(i)
  BASE_PATTERN[i % BASE_PATTERN.size]
end

PHASES.times do |p|
  output = []
  input.size.times do |i|
    total = 0

    i.upto(input.size - 1) do |j|
      num = input[j]
      pattern = pattern_for_index((j - i) / (i + 1) + 1)
      res = num * pattern

      total += res
    end

    output << total.to_s.split('')[-1]
  end

  puts output.take(8).join('') if p + 1 == PHASES
  input = output.map(&:to_i)
end

