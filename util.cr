def get_arg (name)
        match = ARGV.find { |a| a.starts_with? "--#{name}=" }

        return nil if match.nil?

        match.gsub "--#{name}=", ""
end

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

class Perlin
        @@permutation = [151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180]

        def self.p
                @@permutation + @@permutation
        end

        def self.noise (x, y, z)
                xx = x.to_i32 & 255 # FIND UNIT CUBE THAT
                yy = y.to_i32 & 255    # CONTAINS POINT.
                zz = z.to_i32 & 255
                x -= x.to_i32      # FIND RELATIVE xx,yy,zz
                y -= y.to_i32      # OF POINT IN CUBE.
                z -= z.to_i32
                u = fade(x)        # COMPUTE FADE CURVES
                v = fade(y)        # FOR EACH OF xx,yy,zz.
                w = fade(z)
                a = p[xx  ]+yy; aa = p[a]+zz; ab = p[a+1]+zz      # HASH COORDINATES OF
                b = p[xx+1]+yy; ba = p[b]+zz; bb = p[b+1]+zz      # THE 8 CUBE CORNERS,

                return lerp(w, lerp(v, lerp(u, grad(p[aa  ], x  , y  , z   ),  # and add
                                            grad(p[ba  ], x-1, y  , z   )), # blended
                lerp(u, grad(p[ab  ], x  , y-1, z   ),  # results
                     grad(p[bb  ], x-1, y-1, z   ))),# from  8
                lerp(v, lerp(u, grad(p[aa+1], x  , y  , z-1 ),  # corners
                             grad(p[ba+1], x-1, y  , z-1 )), # of cube
                lerp(u, grad(p[ab+1], x  , y-1, z-1 ),
                     grad(p[bb+1], x-1, y-1, z-1 ))))
        end

        def self.lerp (t, a, b)
                a + t * (b - a)
        end

        def self.grad(hash, x, y, z)
                h = hash & 15
                u = h < 8 ? x : y
                v = if h < 4
                        y
                    elsif (12..14).includes? h
                        x
                    else
                        z
                    end
                res = h&1 == 0 ? u : -u
                res += h&2 == 0 ? v : -v
                res
        end

        def self.fade (t)
                t ** 3 * (t * (t * 6 - 15) + 10)
        end
end
