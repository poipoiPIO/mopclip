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
end;
