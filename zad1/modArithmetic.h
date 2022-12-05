#ifndef MOD_ARITHMETIC_H
#define MOD_ARITHMETIC_H

#include <errno.h>

typedef enum EArithmeticError {
  ZERO_DIVISION = 1,
  NO_INVERSION = 2,
} EArithmeticError;

static inline long long addMod(long long a, long long b, long long base);
static inline long long subMod(long long a, long long b, long long base);
static inline long long multMod(long long a, long long b, long long base);
static inline long long divMod(long long a, long long b, long long base);
static inline long long absMod(long long a, long long base);
static inline long long powMod(long long a, long long b, long long base);
static inline long long gcd(long long a, long long b);


static inline long long addMod(long long a, long long b, long long base) {
  a = absMod(a, base);
  b = absMod(b, base);
  return (a + b) % base;
}

static inline long long subMod(long long a, long long b, long long base) {
  a = absMod(a, base);
  b = -b;
  b = absMod(b, base);
  return (a + b) % base;
}

static inline long long multMod(long long a, long long b, long long base) {
  a = absMod(a, base);
  b = absMod(b, base);
  return (a * b) % base;
}

static inline long long divMod(long long a1, long long b1, long long base) {
  a1 = absMod(a1, base);
  b1 = absMod(b1, base);
  
  if (b1 == 0) {
    errno = ZERO_DIVISION;
    return 0;
  }

  if (gcd(b1, base) != 1) {
    errno = NO_INVERSION;
    return 0;
  }

  long long m = base;
  long long m0 = m;
  long long a = b1;
  long long y = 0;
  long long x = 1;

  while (a > 1) {
    long long q = a / m;
    long long t = m;
    m = a % m; 
    a = t;
    t = y;

    y = x - q * y;
    x = t;
  }

  if (x < 0) {
    x += m0;
  }

  return multMod(a1, x, base);
}

static inline long long powMod(long long a, long long b, long long base) {
  long long res = 1;
  a = absMod(a, base);

  if (b < 0) {
    b = -b;
    a = divMod(1, a, base);
  }

  b %= base;

  while (b > 0) {
    if (b % 2 == 1) { res = (res * a) % base; }
    b = b >> 1;
    a = (a * a) % base;
  }
  return res % base;
}

static inline long long absMod(long long a, long long base) {
  if (a < 0) {
    a = -a;
    a %= base;
    return (base - a) % base;
  }

  return a % base;
}

static inline long long gcd(long long a, long long b) {
  while (b > 0) {
    long long c = a % b;
    a = b;
    b = c;
  }
  return a;
}

#endif //MOD_ARITHMETIC_H