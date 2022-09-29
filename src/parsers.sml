structure Parsers = struct
  open Helpers;
  open Types;
  open Combinators;

  fun charP (c: char) = let 
    fun inner ("":string) = Failure "No more input"
      | inner ( i:string) = let
        val e = explode i 
        val first = hd e in 
        if first = c then 
          let val rest = tl e |> implode in 
           (c, rest) |> Success
          end
        else 
          ["Excepted character: ", (str c), ", But: ", (str first), " was found"]
            |> concat
            |> Failure
      end
    in Parser inner 
  end;

  fun choice (parsers: 'a parser list) =
    parsers |> reduce orElse_postfix

  fun anyOf (charList: char list) = 
    charList |> map charP |> choice

  val digitP = let
    val range = 
      List.tabulate(10, fn x => Int.toString x |> explode |> hd) in
    anyOf range
  end;

  fun concatRes (p1: 'a list parser) (p2: 'a list parser) =
    mapP ((andThen (p1, p2)), (fn (l1, l2) => l1 @ l2));

  fun sequenceP (parsers: 'a parser list) = 
  let fun singleton e = [e] in
    parsers |> map (fn p => mapP (p, singleton)) |> reduce concatRes
  end

  fun stringP (s:string) = mapP(explode s |> map charP |> sequenceP, implode)

  val lowerCharP = anyOf $ explode "abcdefghijklmnopqrstuvwxyz";
  val upperCharP = anyOf $ explode "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  val anyCharP = orElse_postfix lowerCharP upperCharP
end;
