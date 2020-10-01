require "stumpy_png"
require "benchmark"

require "./util.cr"

include StumpyPNG

width = (get_arg("width") || "1024").to_i32
height = (get_arg("height") || "512").to_i32
light_power = (get_arg("light-power") || "0,2").split(",").map(&.to_f32)
light_power = light_power[0]..light_power[1]
num_lines = (get_arg("num-lines") || "10").to_u32
out_file = (get_arg("out-file") || "out.png")

canvas = Canvas.new(width, height)

points = Array.new(num_lines) do
        line(

                rand(10...width-10), rand(10...height-10),
                rand(10...width-10), rand(10...height-10),
        ) do |x, y|
                { x, y, rand(light_power) }
        end
end.flatten

(0...width).each do |x|
        (0...height).each do |y|
                canvas[x, y] = RGBA.new(0)
        end
end

iter_count = 0.to_u64
iterations = width.to_u64 * height * points.size

num_threads = (ENV["CRYSTAL_WORKERS"]? || "4").to_i32
channel = Channel(Nil).new

num_threads.times do |thread_num|
        spawn do
                (0...width).each do |x1|
                        next unless x1 % num_threads == thread_num

                        (0...height).each do |y1|
                                power = 0
                                points.each do |x2, y2, v2|
                                        dist = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)

                                        if dist == 0
                                                power += v2
                                        else
                                                power += v2 / (dist ** 2)
                                        end
                                end

                                power *= 2 ** 16
                                power = power.clamp(0..((2**16) - 1))

                                canvas[x1, y1] = RGBA.from_rgb_n(power, power, power, 16)
                        end
                end
                channel.send nil
        end
end

num_threads.times { channel.receive }


StumpyPNG.write(canvas, out_file, filter_method: 0)

def line (x0, y0, x1, y1)
        if x1 < x0
                x0, x1 = x1, x0
                y0, y1 = y1, y0
        end

        dx = x1 - x0
        dy = y1 - y0
        derr = (dy / dx).abs
        err = 0.0
        y = y0
        (x0...x1).map do |x|
                res = yield ({x, y})
                err += derr
                if err >= 0.5
                        y += dy.sign
                        err -= 1.0
                end
                res
        end
end

def circle (cx, cy, r)
        x = r
        y = 0

        yield ({cx + r, cy + 0})
        if r > 0
                yield ({cx + 0, cy - r})
                yield ({cx - r, cy + 0})
                yield ({cx + 0, cy + r})
        end

        p = 1 - r
        while x > y

                y += 1

                if p <= 0
                        p = p + 2 * y + 1
                else
                        x -= 1
                        p = p + 2 * y - 2 * x + 1
                end
                next if x < y

                yield ({cx + x, cy + y})
                yield ({cx - x, cy + y})
                yield ({cx + x, cy - y})
                yield ({cx - x, cy - y})

                if x != y
                        yield ({cx + y, cy + x})
                        yield ({cx - y, cy + x})
                        yield ({cx + y, cy - x})
                        yield ({cx - y, cy - x})
                end
        end
end

def circle2 (cx, cy, r)
        x = 0
        y = r
        d = 3 - 2 * r

        yield ({cx + x, cx + y})
        yield ({cx - x, cx + y})
        yield ({cx + x, cx - y})
        yield ({cx - x, cx - y})
        yield ({cx + y, cx + x})
        yield ({cx - y, cx + x})
        yield ({cx + y, cx - x})
        yield ({cx - y, cx - x})

        while y >= x
                x += 1

                if d > 0
                        y -= 1
                        d = d + 4 * (x - y) + 10
                else
                        d = d + 4 * x + 6
                end

                yield ({cx + x, cx + y})
                yield ({cx - x, cx + y})
                yield ({cx + x, cx - y})
                yield ({cx - x, cx - y})
                yield ({cx + y, cx + x})
                yield ({cx - y, cx + x})
                yield ({cx + y, cx - x})
                yield ({cx - y, cx - x})
        end
end
