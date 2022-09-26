structure Combinators = struct
  open Helpers;
  open Types;

  fun andThen_postfix (p1: 'a parser) (p2: 'a parser) =
    let fun inner input =
      let val firstRes = runParser p1 input in
        case firstRes of 
           Failure err => Failure err
         | Success (res1, rest1) =>
          let val secondRes = runParser p2 rest1 in
            case secondRes of 
               Failure err => Failure err
             | Success (res2, rest2) => Success ((res1, res2), rest2)
          end
      end
    in Parser inner
  end;

  fun mapP_postfix (p1: 'a parser) f =
    let fun inner input = let
      val firstRes = runParser p1 input in
        case firstRes of 
           Success (result, rest) => Success (f result, rest) 
         | Failure err => Failure err
    end in Parser inner
  end;

  fun orElse_postfix (p1: 'a parser) (p2: 'a parser) =
    let fun inner input = let
      val firstRes = runParser p1 input in
        case firstRes of 
           Success _ => firstRes 
         | Failure err => let
            val secondRes = runParser p2 input in
            case secondRes of 
               Failure err => Failure err
             | Success _ => secondRes
          end
    end in Parser inner
  end;

  fun errorC (label: string) (p: 'a parser) = 
  Parser (fn s => 
    let val p_result = runParser p s in  
      case p_result of
         Failure e => label ^ " :: " ^ e |> Failure 
       | Success _ => p_result
    end
  );

  fun left_applicative (p1: 'a parser) (p2: 'a parser) = 
  Parser (fn s =>
    let val p1_result = runParser p1 s in
      case p1_result of
          Failure _ => p1_result
        | Success (p1_res, rest) => let
          val p2_result = runParser p2 rest in 
            case p2_result of
                Failure _ => p2_result
              | Success (_, rest) => Success (p1_res, rest) 
          end
    end
  );

  fun right_applicative (p1: 'a parser) (p2: 'a parser) = 
  Parser (fn s =>
    let val p1_result = runParser p1 s in
      case p1_result of
          Failure _ => p1_result
        | Success (_, rest) => runParser p2 rest
    end
  );

  infix mapP    fun p1 mapP p2 = mapP_postfix p1 p2;
  infix orElse  fun p1 orElse p2 = orElse_postfix p1 p2;
  infix andThen fun p1 andThen p2 = andThen_postfix p1 p2;
  infix *>      fun p1 *> p2 = right_applicative p1 p2;
  infix <*      fun p1 <* p2 = left_applicative p1 p2;
end;

