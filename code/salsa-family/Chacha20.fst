module Chacha20

open FStar.Buffer
open Hacl.Spec.Endianness
open Hacl.Impl.Chacha20

module U32 = FStar.UInt32

#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 100"

val chacha20_key_block:
  block:uint8_p{length block = 64} ->
  k:uint8_p{length k = 32 /\ disjoint block k} ->
  n:uint8_p{length n = 12 /\ disjoint block n} ->
  ctr:UInt32.t ->
  Stack unit
    (requires (fun h -> live h block /\ live h k /\ live h n))
    (ensures (fun h0 _ h1 -> live h1 block /\ modifies_1 block h0 h1 /\ live h0 k /\ live h0 n
      /\ (let block = reveal_sbytes (as_seq h1 block) in
         let k     = reveal_sbytes (as_seq h0 k) in
         let n     = reveal_sbytes (as_seq h0 n) in
         block == Spec.Chacha20.chacha20_block k n (UInt32.v ctr))
     ))
let chacha20_key_block block k n ctr =
  push_frame();
  let st = alloc () in
  let l  = init st k n in
  let l  = chacha20_block l block st ctr in
  pop_frame()


let op_String_Access (h:HyperStack.mem) (m:uint8_p{live h m}) = reveal_sbytes (as_seq h m)

open Spec.Chacha20

val chacha20:
  output:uint8_p ->
  plain:uint8_p{disjoint output plain} ->
  len:U32.t{U32.v len = length output /\ U32.v len = length plain} ->
  key:uint8_p{length key = 32} ->
  nonce:uint8_p{length nonce = 12} ->
  ctr:U32.t{U32.v ctr + (length plain / 64) < pow2 32} ->
  Stack unit
    (requires (fun h -> live h output /\ live h plain /\ live h nonce /\ live h key))
    (ensures (fun h0 _ h1 -> live h1 output /\ live h0 plain /\ modifies_1 output h0 h1
      /\ live h0 nonce /\ live h0 key /\
      h1.[output] == chacha20_encrypt_bytes h0.[key] h0.[nonce] (U32.v ctr) h0.[plain]))
let chacha20 output plain len k n ctr = chacha20 output plain len k n ctr
