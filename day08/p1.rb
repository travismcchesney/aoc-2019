WIDTH = 25
HEIGHT = 6

pixels = []

File.open('input.txt').each do |line|
  line.strip!
  pixels.push(*line.split('').map(&:to_i))
end

def num_layers(width, height, num_pixels)
  num_pixels / (width * height)
end

def layer_bounds(width, height, layer)
  lower = (width * height * (layer - 1))
  upper = (width * height * layer) - 1

  [lower, upper]
end

min_zeros_in_layer = 150
layer_with_min_zeros = 0

1.upto(num_layers(WIDTH, HEIGHT, pixels.size)).each do |i|
  puts "LAYER #{i}"
  lower, upper = layer_bounds(WIDTH, HEIGHT, i)

  layer = pixels[lower..upper]

  zeros_in_layer = layer.reduce(0) do |num_zeros, pixel|
    num_zeros += 1 if pixel.zero?
    num_zeros
  end

  puts zeros_in_layer
  if zeros_in_layer < min_zeros_in_layer
    min_zeros_in_layer = zeros_in_layer
    layer_with_min_zeros = i
  end
end

puts "Layer with max zeros: #{layer_with_min_zeros}"

lower, upper = layer_bounds(WIDTH, HEIGHT, layer_with_min_zeros)

layer = pixels[lower..upper]

num_ones, num_twos = layer.reduce([0, 0]) do |sum, pixel|
  puts pixel
  case pixel
  when 1
    sum[0] += 1
  when 2
    sum[1] += 1
  end
  sum
end

puts num_ones * num_twos
