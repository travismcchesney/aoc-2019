input = []

File.open('input.txt').each do |line|
  input.push(*line.split(',').map(&:to_i))
end

input.freeze

def run_program(prog)
  (0..prog.length).step(4) do |n|
    case prog[n]
    when 1
      prog[prog[n + 3]] = prog[prog[n + 1]] + prog[prog[n + 2]]
    when 2
      prog[prog[n + 3]] = prog[prog[n + 1]] * prog[prog[n + 2]]
    when 99
      break
    end
  end

  prog
end

def simulate(input, noun, verb)
  prog = input.map(&:clone)

  prog[1] = noun
  prog[2] = verb

  run_program(prog)
end

0.upto(99) do |noun|
  0.upto(99) do |verb|
    res = simulate(input, noun, verb)

    if res[0] == 19_690_720
      puts(100 * noun + verb)
      break
    end
  end
end
