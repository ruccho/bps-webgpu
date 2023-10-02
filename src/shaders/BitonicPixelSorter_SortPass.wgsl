struct type__Globals {
  /* @offset(0) */
  thresholdMin : f32,
  /* @offset(4) */
  thresholdMax : f32,
  /* @offset(8) */
  maxLevels : i32,
  /* @offset(12) */
  ordering : u32,
  /* @offset(16) */
  direction : u32,
}

@group(0) @binding(0) var srcTex : texture_2d<f32>;

@group(0) @binding(2) var<uniform> x_Globals : type__Globals;

var<workgroup> groupCache : array<vec4f, 1024u>;

@group(0) @binding(3) var srcMetaTex : texture_2d<f32>;

// modified by hand: rgba32float -> rgba8unorm
@group(0) @binding(4) var sortTex : texture_storage_2d<rgba8unorm, write>;

var<private> x_3 : vec3u;

var<private> x_4 : vec3u;

fn SortPass_1() {
  var x_58 : array<vec3u, 4u>;
  var x_78 : u32;
  var x_130 : u32;
  var x_146 : u32;
  let x_59 = x_3;
  let x_60 = x_4;
  let x_62 = vec2i(textureDimensions(sortTex));
  let x_67 = (x_Globals.direction != 0u);
  let x_69 = f32(select(x_62.y, x_62.x, x_67));
  let x_76 = u32(ceil((f32(u32(ceil((x_69 * 0.5f)))) * 0.00390625f)));
  x_78 = 0u;
  loop {
    var x_106 : bool;
    var x_107 : bool;
    var x_111 : f32;
    var x_112 : f32;
    var x_117 : f32;
    var x_118 : f32;
    var x_79 : u32;
    if ((x_78 < x_76)) {
    } else {
      break;
    }
    let x_86 = ((256u * x_78) + x_60.x);
    let x_87 = x_59.x;
    let x_88 = (x_86 << 1u);
    let x_94 = textureLoad(srcMetaTex, vec2i(vec2u(select(x_87, x_86, x_67), select(x_86, x_87, x_67))), 0u);
    let x_95 = x_94.x;
    let x_98 = ((u32(x_95) % 2u) > 0u);
    let x_99 = select(x_88, (x_88 + 1u), x_98);
    let x_100 = x_94.y;
    x_107 = false;
    if (((x_100 - x_95) > 1.0f)) {
      x_106 = (f32(x_99) <= x_100);
      x_107 = x_106;
    }
    if (x_107) {
      x_112 = x_95;
    } else {
      x_111 = f32(x_99);
      x_112 = x_111;
    }
    let x_113 = u32(x_112);
    if (x_107) {
      x_118 = x_100;
    } else {
      x_117 = f32(x_99);
      x_118 = x_117;
    }
    x_58[x_78] = vec3u(bitcast<u32>((select(0i, 1i, x_107) + select(0i, 2i, x_98))), x_113, u32(x_118));

    continuing {
      x_79 = (x_78 + 1u);
      x_78 = x_79;
    }
  }
  let x_128 = u32(ceil((x_69 * 0.00390625f)));
  x_130 = 0u;
  loop {
    var x_131 : u32;
    if ((x_130 < x_128)) {
    } else {
      break;
    }

    continuing {
      let x_137 = ((x_130 * 256u) + x_60.x);
      let x_138 = x_59.x;
      groupCache[x_137] = textureLoad(srcTex, vec2i(vec2u(select(x_138, x_137, x_67), select(x_137, x_138, x_67))), 0u);
      x_131 = (x_130 + 1u);
      x_130 = x_131;
    }
  }
  x_146 = 0u;
  loop {
    var x_160 : u32;
    var x_147 : u32;
    let x_151 = bitcast<u32>(x_Globals.maxLevels);
    if ((x_146 < x_151)) {
    } else {
      break;
    }
    let x_156 = (x_146 == (x_151 - 1u));
    let x_158 = (1u << (x_146 & 31u));
    x_160 = x_158;
    loop {
      var x_168 : bool;
      var x_169 : bool;
      var x_171 : u32;
      var x_161 : u32;
      if ((x_160 > 0u)) {
      } else {
        break;
      }
      x_169 = false;
      if (x_156) {
        x_168 = (x_160 == 1u);
        x_169 = x_168;
      }
      workgroupBarrier();
      x_171 = 0u;
      loop {
        var x_172 : u32;
        if ((x_171 < x_76)) {
        } else {
          break;
        }
        let x_181 = x_59.x;
        let x_183 = x_58[x_171];
        let x_184 = x_183.y;
        let x_185 = x_183.z;
        let x_195 = ((((((256u * x_171) + x_60.x) << 1u) - x_184) + bitcast<u32>(select(0i, 1i, ((x_183.x & 2u) > 0u)))) / 2u);
        let x_215 = u32(fma((floor(f32((x_195 / x_160))) * f32(x_160)), 2.0f, f32((x_184 + (x_195 % x_160)))));
        let x_216 = (x_215 + x_160);
        let x_218 = select(x_215, x_216, (x_216 <= x_185));
        let x_223_save = x_215;
        let x_224 = groupCache[x_215];
        let x_225_save = x_218;
        let x_226 = groupCache[x_218];
        let x_243 = vec4<bool>((((((x_195 / x_158) % 2u) == 0u) == ((((((x_185 - x_184) + 1u) / (1u << ((x_146 + 1u) & 31u))) % 2u) == 0u) == (x_Globals.ordering != 0u))) == (clamp(fma(0.11447799950838088989f, x_224.z, fma(0.29891198873519897461f, x_224.x, (0.58661097288131713867f * x_224.y))), 0.0f, 1.0f) < clamp(fma(0.11447799950838088989f, x_226.z, fma(0.29891198873519897461f, x_226.x, (0.58661097288131713867f * x_226.y))), 0.0f, 1.0f))));
        let x_244 = select(x_226, x_224, x_243);
        let x_245 = select(x_224, x_226, x_243);
        if (x_169) {
          textureStore(sortTex, vec2i(vec2u(select(x_181, x_215, x_67), select(x_215, x_181, x_67))), x_244);
          textureStore(sortTex, vec2i(vec2u(select(x_181, x_218, x_67), select(x_218, x_181, x_67))), x_245);
        } else {
          groupCache[x_223_save] = x_244;
          groupCache[x_225_save] = x_245;
        }

        continuing {
          x_172 = (x_171 + 1u);
          x_171 = x_172;
        }
      }

      continuing {
        x_161 = (x_160 >> 1u);
        x_160 = x_161;
      }
    }

    continuing {
      x_147 = (x_146 + 1u);
      x_146 = x_147;
    }
  }
  return;
}

@compute @workgroup_size(256i, 1i, 1i)
fn SortPass(@builtin(workgroup_id) x_3_param : vec3u, @builtin(local_invocation_id) x_4_param : vec3u) {
  x_3 = x_3_param;
  x_4 = x_4_param;
  SortPass_1();
}
