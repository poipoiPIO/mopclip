open Helpers;
open Types;
open Combinators;

signature PARSERS = sig
  val charP : char -> char parser
  val choice : 'a parser list -> 'a parser
  val anyOf : char list -> char parser
  val digitP : char parser
  val concatRes : 'a list parser -> 'a list parser -> 'a list parser
  val sequenceP : 'a parser list -> 'a list parser
  val stringP : string -> string parser
  val lowerCharP : char parser
  val upperCharP : char parser
  val anyCharP : char parser
end

structure Parsers :> PARSERS = struct
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
    mapP_postfix (andThen_postfix p1 p2) (fn (l1, l2) => l1 @ l2);

  fun sequenceP (parsers: 'a parser list) = 
  let fun singleton e = [e] in
    parsers |> map (fn p => mapP_postfix p singleton) |> reduce concatRes
  end

  fun stringP (s:string) = mapP_postfix (explode s |> map charP |> sequenceP) implode

  val lowerCharP = anyOf $ explode "abcdefghijklmnopqrstuvwxyz";
  val upperCharP = anyOf $ explode "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  val anyCharP = orElse_postfix lowerCharP upperCharP
end;
