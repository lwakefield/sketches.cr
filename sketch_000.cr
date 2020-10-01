require "stumpy_png"
include StumpyPNG

WIDTH = 256
HEIGHT = 128
LIGHT_POWER = 0.5..3.0
NUM_LIGHTS = 3

canvas = Canvas.new(WIDTH, HEIGHT)

points = Array.new(NUM_LIGHTS) do
        { rand(0 + 10...WIDTH - 10), rand(0 + 10...HEIGHT - 10), rand(LIGHT_POWER) }
end

(0...WIDTH).each do |x1|
        (0...HEIGHT).each do |y1|
                power = 0
                points.each do |x2, y2, v2|
                        dist = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)

                        if dist == 0
                                power += v2
                        else
                                power += v2 / dist
                        end
                end

                power *= 255
                power = power.clamp(0..255)

                canvas[x1, y1] = RGBA.from_rgb_n(power, power, power, 8)
        end
end

StumpyPNG.write(canvas, ARGV.first, filter_method: 0)
