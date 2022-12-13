#ifndef _CHOO_NOISE 
#define _CHOO_NOISE
#endif

#define s uint3(0x456789ab, 0x6789ab45, 0x89ab4567)
#define u uint3(1, 2, 3)
#define UINT_MAX uint(0xffffffff)

/* *** *** */
/* *** *** */

/* *** UINT HASH *** */
uint uhash11(uint n) {
    n = n ^ (n << 1);
    n = n ^ (n >> 1);
    n *= s.x;
    n = n ^ (n << 1);
    return n * s.x;
}

uint2 uhash22(uint2 n) {
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= s.xy;
    n ^= (n.yx << u.xy);
    return n * s.xy;
}

uint3 uhash33(uint3 n) {
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= s;
    n ^= (n.yzx << u);
    return n * s;

}
/* *** *** */


/* *** HASH *** */

float hash11(float p) {
    uint n = asuint(p);
    return float(uhash11(n)) / float(UINT_MAX);
}

float hash21(float2 p) {
    uint2 n = asuint(p);
    return float(uhash22(n).x) / float(UINT_MAX);
}

float2 hash22(float2 p) {
    uint2 n = asuint(p);
    return float2(uhash22(n)) / float(UINT_MAX);
}

float hash31(float3 p) {
    uint3 n = asuint(p);
    return float(uhash33(n).x) / float(UINT_MAX);
}

float3 hash33(float3 p) {
    uint3 n = asuint(p);
    return float3(uhash33(n)) / float(UINT_MAX);
}

/* *** *** */

/* *** Value Noise *** */
float ValueNoise21(float2 p) {
    float2 n = floor(p);
    float v[4];

    [unroll]
    for (int j=0; j<2; j++) {
        for(int i=0; i<2; i++) {
            v[i+2*j] = hash21(n + float2(i, j));
        }
    }

    float2 f = frac(p);
    f = f * f * (3.0 - 2.0 * f); // Hermite interpolation

    return lerp(
        lerp(v[0], v[1], f[0]),
        lerp(v[2], v[3], f[0]),
        f[1]
    );

}

float ValueNoise31(float3 p) {
    float3 n = floor(p);
    float v[8];

    [unroll]
    for (int k=0; k<2; k++) {
        for (int j=0; j<2; j++) {
            for (int i=0; i<2; i++) {
                v[i+2*j+4*k] = hash31(n + float3(i, j, k));
            }
        }
    }

    float3 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);

    float w[2];
    
    [unroll]
    for (int i=0; i<2; i++) {
        w[i] = lerp(
            lerp(v[4*i], v[4*i+1], f[0]),
            lerp(v[4*i+2], v[4*i+3], f[0]),
            f[1]);
    }

    return lerp(w[0], w[1], f[2]);
}

/* *** *** */

/* *** Perlin Noise *** */
float PerlinNoise21(float2 p) {
    float2 n = floor(p);
    float2 f = frac(p);

    float v[4];

    [unroll]
    for (int j=0; j<2; j++) {
        for (int i=0; i<2; i++) {
            float2 g = normalize(hash22(n + float2(i, j)) - float2(0.5, 0.5));
            v[i+2*j] = dot(g, f - float2(i, j));
        }
    }

    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    float r = lerp(
        lerp(v[0], v[1], f[0]),
        lerp(v[2], v[3], f[0]), 
        f[1]
    );

    return 0.5 * r + 0.5;
}

float PerlinNoise31(float3 p) {
    float3 n = floor(p);
    float3 f = frac(p);

    float v[8];

    [unroll]
    for (int k=0; k<2; k++) {
        for (int j=0; j<2; j++) {
            for (int i=0; i<2; i++) {
                float3 g = normalize(hash33(n + float3(i, j, k)) - float3(0.5, 0.5, 0.5));
                v[i+2*j+4*k] = dot(g, f - float3(i, j, k));
            }
        }
    }

    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);

    float w[2];

    [unroll]
    for (int i=0; i<2; i++) {
        w[i] = lerp(
            lerp(v[4*i], v[4*i+1], f[0]),
            lerp(v[4*i+2], v[4*i+3], f[0]),
            f[1]
        );
    }

    float r = lerp(w[0], w[1], f[2]);
    return 0.5 * r + 0.5;
}

/* *** *** */