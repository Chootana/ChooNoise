#ifndef _CHOO_NOISE 
#define _CHOO_NOISE
#endif

#define k uint3(0x456789ab, 0x6789ab45, 0x89ab4567)
#define u uint3(1, 2, 3)
#define UINT_MAX uint(0xffffffff)

/* *** *** */
/* *** *** */

/* *** UINT HASH *** */
uint uhash11(uint n) {
    n = n ^ (n << 1);
    n = n ^ (n >> 1);
    n *= k.x;
    n = n ^ (n << 1);
    return n * k.x;
}

uint2 uhash22(uint2 n) {
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= k.xy;
    n ^= (n.yx << u.xy);
    return n * k.xy;
}

uint3 uhash33(uint3 n) {
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= k;
    n ^= (n.yzx << u);
    return n * k;

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
    for (int a=0; a<2; a++) {
        for (int b=0; b<2; b++) {
            for (int c=0; c<2; c++) {
                v[a+2*b+4*c] = hash31(n + float3(a, b, c));
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
    for (int a=0; a<2; a++) {
        for (int b=0; b<2; b++) {
            for (int c=0; c<2; c++) {
                float3 g = normalize(hash33(n + float3(a, b, c)) - float3(0.5, 0.5, 0.5));
                v[a+2*b+4*c] = dot(g, f - float3(a, b, c));
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