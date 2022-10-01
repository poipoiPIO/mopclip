
infix mapP    fun p1 mapP p2    = Combinators.mapP_postfix p1 p2;
infix orElse  fun p1 orElse p2  = Combinators.orElse_postfix p1 p2;
infix andThen fun p1 andThen p2 = Combinators.andThen_postfix p1 p2;
infix >>      fun p1 >> p2      = Combinators.pass_bind p1 p2;
infix >>=     fun p1 >>= p2     = Combinators.bind p1 p2;
infix sepBy   fun p1 sepBy p2   = Combinators.sepByC p1 p2;
infix *>      fun p1 *> p2      = Combinators.right_applicative p1 p2;
infix <*      fun p1 <* p2      = Combinators.left_applicative p1 p2;

structure Mopclip = struct
  open Helpers;
  open Types;
  open Parsers;
  open Combinators;
end;
