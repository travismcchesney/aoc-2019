$stdout.sync = true

WIDTH = 25
HEIGHT = 6

#WIDTH = 2
#HEIGHT = 2

pixels = []
output = []

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

1.upto(num_layers(WIDTH, HEIGHT, pixels.size)).each do |i|
  lower, upper = layer_bounds(WIDTH, HEIGHT, i)

  layer = pixels[lower..upper]

  layer.each_with_index do |pixel, j|
    out_pixel = output[j]
    if out_pixel
      if out_pixel == 2 && (pixel == 1  || pixel == 0)
        #puts "Setting out_pixel #{j} to #{pixel}"
        output[j] = pixel
      end
    else
      #puts "Setting out_pixel #{j} to #{pixel}"
      output[j] = pixel
    end
  end
end

output.each_with_index do |pixel, i|
  #puts i
  i += 1
  pixel = ' ' if pixel == 0
  pixel = '*' if pixel == 1
  if i % 25 == 0
    print "#{pixel}\n"
  else
    print pixel
  end
end
