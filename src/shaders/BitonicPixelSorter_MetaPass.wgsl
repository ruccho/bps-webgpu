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

var<workgroup> metaGroupCache : array<u32, 4096u>;

@group(0) @binding(1) var metaTex : texture_storage_2d<rg32float, write>;

@group(0) @binding(2) var<uniform> x_Globals : type__Globals;

var<private> x_3 : vec3u;

var<private> x_4 : vec3u;

fn MetaPass_1() {
  var x_86 : i32;
  var x_87 : i32;
  var x_97 : u32;
  var x_98 : u32;
  var x_104 : u32;
  var x_107 : i32;
  var x_109 : u32;
  var x_234 : i32;
  var x_237 : u32;
  let x_65 = vec2i(textureDimensions(srcTex, 0i));
  let x_72 = (x_Globals.direction != 0u);
  let x_74 = bitcast<u32>(select(bitcast<i32>(x_65.y), bitcast<i32>(x_65.x), x_72));
  let x_77 = x_4.x;
  let x_78 = ((x_3.x * 32u) + x_77);
  let x_80 = ((x_78 % 2u) == 0u);
  let x_81 = (x_78 / 2u);
  let x_82 = (x_77 / 2u);
  if (x_80) {
    x_86 = bitcast<i32>(x_74);
    x_87 = x_86;
  } else {
    x_87 = -1i;
  }
  let x_93 = u32((round(f32((bitcast<i32>(x_74) / 8i))) * 4.0f));
  if (x_80) {
    x_98 = x_93;
  } else {
    x_97 = (x_74 - x_93);
    x_98 = x_97;
  }
  let x_102 = u32(ceil((f32(x_74) * 0.25f)));
  x_104 = 0u;
  x_107 = x_87;
  x_109 = 0u;
  loop {
    var x_118 : u32;
    var x_119 : u32;
    var x_144 : bool;
    var x_145 : bool;
    var x_150 : bool;
    var x_151 : bool;
    var x_167 : bool;
    var x_168 : bool;
    var x_178 : u32;
    var x_185 : u32;
    var x_186 : u32;
    var x_197 : u32;
    var x_204 : u32;
    var x_205 : u32;
    var x_227 : u32;
    var x_228 : u32;
    var x_110 : u32;
    if ((x_109 < x_98)) {
    } else {
      break;
    }
    if (x_80) {
      x_119 = x_109;
    } else {
      x_118 = ((x_74 - x_109) - 1u);
      x_119 = x_118;
    }
    let x_121 = ((x_119 / 2u) << 1u);
    let x_122 = (x_121 + 1u);
    let x_123 = select(x_122, x_121, x_80);
    let x_124 = select(x_121, x_122, x_80);
    let x_130 = vec2u(select(x_81, x_124, x_72), select(x_124, x_81, x_72));
    let x_131 = textureLoad(srcTex, vec2i(vec2u(select(x_81, x_123, x_72), select(x_123, x_81, x_72))), 0u);
    let x_138 = clamp(fma(0.11447799950838088989f, x_131.z, fma(0.29891198873519897461f, x_131.x, (0.58661097288131713867f * x_131.y))), 0.0f, 1.0f);
    x_145 = false;
    if ((x_123 < x_74)) {
      x_144 = (x_Globals.thresholdMin <= x_138);
      x_145 = x_144;
    }
    x_151 = false;
    if (x_145) {
      x_150 = (x_138 <= x_Globals.thresholdMax);
      x_151 = x_150;
    }
    let x_152 = textureLoad(srcTex, vec2i(x_130), 0u);
    let x_159 = clamp(fma(0.11447799950838088989f, x_152.z, fma(0.29891198873519897461f, x_152.x, (0.58661097288131713867f * x_152.y))), 0.0f, 1.0f);
    let x_161 = x_Globals.thresholdMin;
    x_168 = false;
    if ((x_161 <= x_159)) {
      x_167 = (x_159 <= x_Globals.thresholdMax);
      x_168 = x_167;
    }
    var x_177 : u32;
    var x_183 : i32;
    var x_184 : i32;
    if (x_80) {
      if (x_151) {
        x_177 = bitcast<u32>(min(x_107, bitcast<i32>(x_123)));
        x_178 = x_177;
      } else {
        x_178 = x_74;
      }
      x_186 = x_178;
    } else {
      if (x_151) {
        x_183 = max(x_107, bitcast<i32>(x_123));
        x_184 = x_183;
      } else {
        x_184 = -1i;
      }
      x_185 = bitcast<u32>(x_184);
      x_186 = x_185;
    }
    var x_196 : u32;
    var x_202 : i32;
    var x_203 : i32;
    let x_187 = bitcast<i32>(x_186);
    if (x_80) {
      if (x_168) {
        x_196 = bitcast<u32>(min(x_187, bitcast<i32>(x_124)));
        x_197 = x_196;
      } else {
        x_197 = x_74;
      }
      x_205 = x_197;
    } else {
      if (x_168) {
        x_202 = max(x_187, bitcast<i32>(x_124));
        x_203 = x_202;
      } else {
        x_203 = -1i;
      }
      x_204 = bitcast<u32>(x_203);
      x_205 = x_204;
    }
    let x_108 = bitcast<i32>(x_205);
    let x_209 = ((x_82 * x_102) + (x_119 / 4u));
    let x_215 = (select(0u, 1u, ((x_119 % 4u) < 2u)) != 0u);
    let x_223 = (((bitcast<u32>(select(x_108, x_187, x_151)) & 16383u) | bitcast<u32>(select(0i, 32768i, select(x_168, x_151, x_80)))) | bitcast<u32>(select(0i, 16384i, select(x_151, x_168, x_80))));
    if (x_215) {
      x_228 = x_223;
    } else {
      x_227 = (x_223 << 16u);
      x_228 = x_227;
    }
    let x_105 = ((x_104 & bitcast<u32>(select(65535i, -65536i, x_215))) | x_228);
    metaGroupCache[x_209] = x_105;

    continuing {
      x_110 = (x_109 + 2u);
      x_104 = x_105;
      x_107 = x_108;
      x_109 = x_110;
    }
  }
  workgroupBarrier();
  x_234 = x_107;
  x_237 = x_98;
  loop {
    var x_246 : u32;
    var x_247 : u32;
    var x_263 : u32;
    var x_264 : u32;
    var x_287 : u32;
    var x_294 : u32;
    var x_295 : u32;
    var x_306 : u32;
    var x_313 : u32;
    var x_314 : u32;
    var x_238 : u32;
    if ((x_237 < x_74)) {
    } else {
      break;
    }
    if (x_80) {
      x_247 = x_237;
    } else {
      x_246 = ((x_74 - x_237) - 1u);
      x_247 = x_246;
    }
    let x_248 = (x_247 / 2u);
    let x_249 = (x_248 << 1u);
    let x_250 = (x_249 + 1u);
    let x_251 = select(x_250, x_249, x_80);
    let x_252 = select(x_249, x_250, x_80);
    let x_259 = metaGroupCache[((x_82 * x_102) + (x_247 / 4u))];
    if (((x_247 % 4u) < 2u)) {
      x_264 = x_259;
    } else {
      x_263 = (x_259 >> 16u);
      x_264 = x_263;
    }
    var x_286 : u32;
    var x_292 : i32;
    var x_293 : i32;
    let x_266 = ((x_264 & 32768u) != 0u);
    let x_268 = ((x_264 & 16384u) != 0u);
    let x_275 = bitcast<i32>(((x_264 & 16383u) | bitcast<u32>(select(0i, -16384i, ((x_264 & 8192u) != 0u)))));
    let x_276 = select(x_268, x_266, x_80);
    let x_277 = select(x_266, x_268, x_80);
    if (x_80) {
      if (x_276) {
        x_286 = bitcast<u32>(min(x_234, bitcast<i32>(x_251)));
        x_287 = x_286;
      } else {
        x_287 = x_74;
      }
      x_295 = x_287;
    } else {
      if (x_276) {
        x_292 = max(x_234, bitcast<i32>(x_251));
        x_293 = x_292;
      } else {
        x_293 = -1i;
      }
      x_294 = bitcast<u32>(x_293);
      x_295 = x_294;
    }
    var x_305 : u32;
    var x_311 : i32;
    var x_312 : i32;
    let x_296 = bitcast<i32>(x_295);
    if (x_80) {
      if (x_277) {
        x_305 = bitcast<u32>(min(x_296, bitcast<i32>(x_252)));
        x_306 = x_305;
      } else {
        x_306 = x_74;
      }
      x_314 = x_306;
    } else {
      if (x_277) {
        x_311 = max(x_296, bitcast<i32>(x_252));
        x_312 = x_311;
      } else {
        x_312 = -1i;
      }
      x_313 = bitcast<u32>(x_312);
      x_314 = x_313;
    }
    let x_235 = bitcast<i32>(x_314);
    let x_315 = select(x_235, x_296, x_276);
    textureStore(metaTex, vec2i(vec2u(select(x_81, x_248, x_72), select(x_248, x_81, x_72))), vec4f(vec2f(f32(select(x_275, x_315, x_80)), f32(select(x_315, x_275, x_80))), 0.0f, 0.0f));

    continuing {
      x_238 = (x_237 + 2u);
      x_234 = x_235;
      x_237 = x_238;
    }
  }
  return;
}

@compute @workgroup_size(32i, 1i, 1i)
fn MetaPass(@builtin(workgroup_id) x_3_param : vec3u, @builtin(local_invocation_id) x_4_param : vec3u) {
  x_3 = x_3_param;
  x_4 = x_4_param;
  MetaPass_1();
}
