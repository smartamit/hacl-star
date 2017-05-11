module Ed25519

open FStar.Buffer

(* Abbreviations *)
let uint8_p = buffer UInt8.t
let hint8_p = buffer Hacl.UInt8.t
let op_String_Access h b = Hacl.Spec.Endianness.reveal_sbytes (as_seq h b)


val sign:
  signature:hint8_p{length signature = 64} ->
  secret:hint8_p{length secret = 32} ->
  msg:hint8_p{length msg < pow2 32 - 64} ->
  len:UInt32.t{UInt32.v len = length msg} ->
  Stack unit
    (requires (fun h -> live h signature /\ live h msg /\ live h secret))
    (ensures (fun h0 _ h1 -> live h0 signature /\ live h0 msg /\ live h0 secret /\
      live h1 signature /\ modifies_1 signature h0 h1 /\
      h1.[signature] == Spec.Ed25519.sign h0.[secret] h0.[msg]))


val verify:
  public:uint8_p{length public = 32} ->
  msg:uint8_p ->
  len:UInt32.t{length msg = UInt32.v len /\ length msg < pow2 32 - 64} ->
  signature:uint8_p{length signature = 64} ->
  Stack bool
    (requires (fun h -> live h public /\ live h msg /\ live h signature))
    (ensures (fun h0 b h1 -> live h0 public /\ live h0 msg /\ live h0 signature /\
      modifies_0 h0 h1 /\ 
      b == Spec.Ed25519.verify h0.[public] h0.[msg] h0.[signature]))
