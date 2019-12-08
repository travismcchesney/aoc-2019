prog = []

File.open('input.txt').each do |line|
  prog.push(*line.split(',').map(&:to_i))
end

prog.freeze

def run_program(prog, phase, input, first, i)
  while i < prog.length
    # Get the instruction, which for now we left-pad with 0s since the hundreds
    # and higher place digits correspond to parameter modes, and we don't have
    # any op codes that use more than two input parameters. The instruction is
    # constructed like so:
    #
    #   ABCDE
    #   01002
    #
    #   DE - two-digit opcode,      02 == opcode 2
    #    C - mode of 1st parameter,  0 == position mode
    #    B - mode of 2nd parameter,  1 == immediate mode
    #    A - mode of 3rd parameter,  0 == position mode,
    #                                     omitted due to being a leading zero
    instr = prog[i].to_s.rjust(5, '0')

    # The opcode is the last two digits
    op = instr[-2..-1].to_i
    p1 = instr[-3..-3].to_i
    p2 = instr[-4..-4].to_i

    case op
    when 1 # add
      arg1 = p1.zero? ? prog[prog[i + 1]] : prog[i + 1]
      arg2 = p2.zero? ? prog[prog[i + 2]] : prog[i + 2]

      prog[prog[i + 3]] = arg1.to_i + arg2.to_i
      i += 4
    when 2 # multiply
      arg1 = p1.zero? ? prog[prog[i + 1]] : prog[i + 1]
      arg2 = p2.zero? ? prog[prog[i + 2]] : prog[i + 2]

      prog[prog[i + 3]] = arg1.to_i * arg2.to_i
      i += 4
    when 3 # input
      in_val = i.zero? && first ? phase : input
      prog[prog[i + 1]] = in_val
      i += 2
    when 4 # output
      arg1 = p1.zero? ? prog[prog[i + 1]] : prog[i + 1]
      i += 2
      return [arg1, prog, i] # basically the output and program state
    when 5 # jump-if-true
      arg1 = p1.zero? ? prog[prog[i + 1]] : prog[i + 1]
      arg2 = p2.zero? ? prog[prog[i + 2]] : prog[i + 2]

      i = arg1.to_i.zero? ? i + 3 : arg2.to_i
    when 6 # jump-if-false
      arg1 = p1.zero? ? prog[prog[i + 1]] : prog[i + 1]
      arg2 = p2.zero? ? prog[prog[i + 2]] : prog[i + 2]

      i = arg1.to_i.zero? ? arg2.to_i : i + 3
    when 7 # less than
      arg1 = p1.zero? ? prog[prog[i + 1]] : prog[i + 1]
      arg2 = p2.zero? ? prog[prog[i + 2]] : prog[i + 2]

      prog[prog[i + 3]] = arg1.to_i < arg2.to_i ? 1 : 0
      i += 4
    when 8 # equal
      arg1 = p1.zero? ? prog[prog[i + 1]] : prog[i + 1]
      arg2 = p2.zero? ? prog[prog[i + 2]] : prog[i + 2]

      prog[prog[i + 3]] = arg1.to_i == arg2.to_i ? 1 : 0
      i += 4
    when 99 # donezo
      return nil
    end
  end

  prog
end


phases = (5..9).to_a.reverse
max_output = 0

phases.permutation(5) do |combo|
  prog_1 = prog.map(&:clone)
  prog_2 = prog.map(&:clone)
  prog_3 = prog.map(&:clone)
  prog_4 = prog.map(&:clone)
  prog_5 = prog.map(&:clone)
  i_1 = i_2 = i_3 = i_4 = i_5 = 0
  input = 0
  first = true
  res = []

  until res.nil?
    # Amp 1
    res = run_program(prog_1, combo[0], input, first, i_1)
    input = res[0] unless res.nil?
    prog_1 = res[1] unless res.nil?
    i_1 = res[2] unless res.nil?

    # Amp 2
    res = run_program(prog_2, combo[1], input, first, i_2)
    input = res[0] unless res.nil?
    prog_2 = res[1] unless res.nil?
    i_2 = res[2] unless res.nil?

    # Amp 3
    res = run_program(prog_3, combo[2], input, first, i_3)
    input = res[0] unless res.nil?
    prog_3 = res[1] unless res.nil?
    i_3 = res[2] unless res.nil?

    # Amp 4
    res = run_program(prog_4, combo[3], input, first, i_4)
    input = res[0] unless res.nil?
    prog_4 = res[1] unless res.nil?
    i_4 = res[2] unless res.nil?

    # Amp 5
    res = run_program(prog_5, combo[4], input, first, i_5)
    input = res[0] unless res.nil?
    prog_5 = res[1] unless res.nil?
    i_5 = res[2] unless res.nil?

    first = false
  end
  max_output = input > max_output ? input : max_output
end

puts max_output


