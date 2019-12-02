arr = []

File.open('input.txt').each do |line|
  arr.push(*line.split(',').map(&:to_i))
end

(0..arr.length).step(4) do |n|
  case arr[n]
  when 1
    arr[arr[n + 3]] = arr[arr[n + 1]] + arr[arr[n + 2]]
  when 2
    arr[arr[n + 3]] = arr[arr[n + 1]] * arr[arr[n + 2]]
  when 99
    break
  end
end

puts arr.join(',')

