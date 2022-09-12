signature TypeSig = sig
  datatype 'a pResult = Failure of string | Success of 'a
  datatype 'a parser = Parser of string -> ('a * string) pResult
  val runParser : 'a parser -> string -> ('a * string) pResult
end;

structure Types : TypeSig = struct
  open Helpers;

  datatype 'a pResult =
    Success of 'a
    | Failure of string
  ;

  datatype 'a parser =
    Parser of (string -> ('a * string) pResult)
  ;

  fun runParser (p: 'a parser) (i: string) = let
    val (Parser inner) = p in
      inner i
  end;
end;
