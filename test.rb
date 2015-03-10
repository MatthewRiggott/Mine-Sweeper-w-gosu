clicked = Array.new(4) { |i| Array.new(4) { |j| false } }

clicked.each_with_index do |x, row|
  x.each_with_index do |y, column|
    puts "#{row},#{column} = #{y}"
  end
end
