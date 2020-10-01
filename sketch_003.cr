require "./util.cr"

size          = (get_arg("size") || "512x256").split("x").map(&.to_i32)
width, height = size[0], size[1]
light_power   = (get_arg("light-power") || "1").to_f32
num_lights    = (get_arg("num-lights") || "4").to_u32
out_file      = (get_arg("out-file") || "out.ppm")

pixels = Array.new(height) do
        [0f32] * width
end

macro rand_light
        { rand(-(width*0.5).to_i32...(width*1.5).to_i32), rand(-(height*0.5).to_i32...(height*1.5).to_i32) }
end

macro reset_line
        print "\r\e[2K"
end

last_point = rand_light
(num_lights - 1).times do |line_num|
        next_light = rand_light
        x1, y1, x2, y2 = last_point[0], last_point[1], next_light[0], next_light[1]
        line(x1, y1, x2, y2) do |x, y|
                reset_line
                print "rendering line #{line_num} #{x},#{y}"
                power = light_power * ((Perlin.noise(x / 20.0, y / 20.0, 0) + 1.0) / 2.0)
                (0...height).each do |y3|
                        (0...width).each do |x3|
                                dist = Math.sqrt((x3 - x) ** 2 + (y3 - y) ** 2)

                                pixels[y3][x3] += dist == 0 ?  power : power / (dist ** 2)
                        end
                end
        end
        puts
        last_point = next_light
end

File.open(out_file, "w") do |f|
        f << "P3\n"
        f << "#{width} #{height}\n"
        f << "255\n"
        pixels.each_with_index do |row, index|
                reset_line
                print "writing scanline #{index + 1} / #{height}"
                print "\e8"
                row.each do |pixel|
                        val = (pixel * 255).to_i32.clamp(0..255)
                        f << "#{val} #{val} #{val}\n"
                end
        end
end
puts ""
