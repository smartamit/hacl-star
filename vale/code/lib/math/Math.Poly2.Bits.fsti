module Math.Poly2.Bits
open Words_s
open Types_s
open FStar.UInt
open FStar.Seq
open Arch.Types
open Math.Poly2_s
open Math.Poly2.Bits_s
open Math.Poly2
open Math.Poly2.Lemmas

val of_nat (x:nat) : poly

// TODO: of_uint should accept n = 0
let of_uint_ (n:nat) (u:uint_t n) : poly =
  if n = 0 then zero else of_uint n u

val lemma_of_nat_of_uint (n:nat) (x:nat) : Lemma
  (requires x < pow2 n)
  (ensures of_nat x == of_uint_ n x)

let rec poly_nat_eq_rec (len:nat) (p:poly) (c:nat) (n:nat) : bool =
  if n = 0 then c = 0
  else
    (c % 2 = (if p.[len - n] then 1 else 0)) &&
    poly_nat_eq_rec len p (c / 2) (n - 1)

// Useful for proving variable p equivalent to constant c via normalization
// (c and len should be constant integers)
val lemma_to_nat (len:nat) (p:poly) (c:nat) : Lemma
  (requires degree p < len /\ normalize (poly_nat_eq_rec len p c len))
  (ensures p == of_nat c)

val of_nat32 (n:nat32) : p:poly{degree p < 32 /\ p == of_nat n}

val of_nat32_zero : _:unit{of_nat32 0 == zero}

val of_nat32_xor (a b:nat32) : Lemma
  (of_nat32 a +. of_nat32 b == of_nat32 (ixor a b))

let poly128_of_poly32s (a0 a1 a2 a3:poly) : poly =
  a0 +. shift a1 32 +. shift a2 64 +. shift a3 96

let poly128_of_nat32s (a0 a1 a2 a3:nat32) : poly =
  poly128_of_poly32s (of_nat32 a0) (of_nat32 a1) (of_nat32 a2) (of_nat32 a3)

val lemma_quad32_of_nat32s (a0 a1 a2 a3:nat32) : Lemma
  (Mkfour a0 a1 a2 a3 == to_quad32 (poly128_of_nat32s a0 a1 a2 a3))

val lemma_quad32_to_nat32s (a:poly) : Lemma
  (requires degree a <= 127)
  (ensures (
    let Mkfour a0 a1 a2 a3 = to_quad32 a in
    a == poly128_of_nat32s a0 a1 a2 a3
  ))

val lemma_quad32_double (a:poly) : Lemma
  (requires degree a <= 127)
  (ensures
    of_double32 (quad32_double_lo (to_quad32 a)) == a %. monomial 64 /\
    of_double32 (quad32_double_hi (to_quad32 a)) == a /. monomial 64 /\
    a == (a /. monomial 64) *. monomial 64 +. a %. monomial 64 /\
    (a /. monomial 64) *. monomial 64 == shift (a /. monomial 64) 64
  )

val lemma_of_double32_degree (d:double32) : Lemma
  (degree (of_double32 d) < 64)
  [SMTPat (degree (of_double32 d))]

val lemma_of_quad32_degree (q:quad32) : Lemma
  (degree (of_quad32 q) < 128)
  [SMTPat (degree (of_quad32 q))]

val lemma_to_of_quad32 (q:quad32) : Lemma (to_quad32 (of_quad32 q) == q)

val lemma_of_to_quad32 (a:poly) : Lemma
  (requires degree a < 128)
  (ensures of_quad32 (to_quad32 a) == a)

