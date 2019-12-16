reactions = {}

File.open('input.txt').each do |line|
  inputs, output = line.strip.split(' => ')
  inputs = inputs.split(', ').map { |i| i.split(' ') }
  output = output.split(' ')
  reactions[output] = inputs
end

def get_reaction_by_output(reactions, chemical)
  reactions.find { |r_o, _| r_o[1] == chemical }
end

initial_reaction = get_reaction_by_output(reactions, 'FUEL')

def doit(quantity, reactions, requirements, inventory, reaction)
  output = reaction[0]
  inputs = reaction[1]

  inventory[output[1]] ||= 0
  requirements[output[1]] ||= 0

  multiple = [((quantity.to_i - inventory[output[1]]) / output[0].to_f).ceil, 0].max

  if quantity < inventory[output[1]].to_i
    inventory[output[1]] -= quantity
  else
    requirements[output[1]] -= inventory[output[1]]
    inventory[output[1]] = multiple * output[0].to_i - requirements[output[1]] if output[1] != "FUEL"
    inputs.each do |input|
      requirements[input[1]] ||= 0
      requirements[input[1]] += multiple * input[0].to_i
      doit(input[0].to_i * multiple, reactions, requirements, inventory, get_reaction_by_output(reactions, input[1])) if input[1] != "ORE"
    end
  end
  requirements[output[1]] = 0
  requirements['ORE']
end

n = 1000000000000
res = (1..n).bsearch do |i|
  requirements = {}
  inventory = {}
  res = doit(i, reactions, requirements, inventory, initial_reaction)
  res > n
end

puts res - 1
