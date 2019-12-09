input = []

File.open('input.txt').each do |line|
  input.push(*line.split(',').map(&:to_i))
end

input.freeze

def get_arg(prog, mode, curr_i, arg_num, base)
  if mode.zero? # position
    prog[prog[curr_i + arg_num]]
  elsif mode == 1 # immediate
    prog[curr_i + arg_num]
  elsif mode == 2 # relative
    prog[prog[curr_i + arg_num] + base]
  end
end

def write_val(prog, mode, curr_i, arg_num, base, val)
  if mode == 2 # relative
    prog[prog[curr_i + arg_num] + base] = val
  else # immediate
    prog[prog[curr_i + arg_num]] = val
  end
end

def run_program(prog)
  i = 0
  rel_base = 0

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
    p3 = instr[-5..-5].to_i

    case op
    when 1 # add
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i + arg2.to_i)
      i += 4
    when 2 # multiply
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i * arg2.to_i)
      i += 4
    when 3 # input
      puts 'Input:'
      input = gets.chomp
      write_val(prog, p1, i, 1, rel_base, input)
      i += 2
    when 4 # output
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      puts "Output: #{arg1}"
      i += 2
    when 5 # jump-if-true
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      i = arg1.to_i.zero? ? i + 3 : arg2.to_i
    when 6 # jump-if-false
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      i = arg1.to_i.zero? ? arg2.to_i : i + 3
    when 7 # less than
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i < arg2.to_i ? 1 : 0)
      i += 4
    when 8 # equal
      arg1 = get_arg(prog, p1, i, 1, rel_base)
      arg2 = get_arg(prog, p2, i, 2, rel_base)

      write_val(prog, p3, i, 3, rel_base, arg1.to_i == arg2.to_i ? 1 : 0)
      i += 4
    when 9
      arg1 = get_arg(prog, p1, i, 1, rel_base)

      rel_base += arg1
      i += 2
    when 99 # donezo
      return nil
    end
  end

  prog
end

prog = input.map(&:clone)

run_program(prog)
