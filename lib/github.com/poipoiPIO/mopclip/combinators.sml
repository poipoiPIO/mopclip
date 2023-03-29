open Types;

signature COMBINATORS = sig
  val andThen_postfix : 'a parser -> 'b parser -> ('a * 'b) parser
  val mapP_postfix : 'a parser -> ('a -> 'b) -> 'b parser
  val orElse_postfix : 'a parser -> 'a parser -> 'a parser
  val orElse_postfix_rec : (unit ->'a parser) -> (unit -> 'a parser) -> 'a parser
  val errorC : string -> 'a parser -> 'a parser
  val left_applicative : 'a parser -> 'b parser -> 'a parser
  val right_applicative : 'a parser -> 'b parser -> 'b parser
  val bind : 'a parser -> ('a -> 'b parser) -> 'b parser
  val pass_bind : 'a parser -> 'b parser -> 'b parser
  val return : 'a -> 'a parser
  val manyC : 'a parser -> 'a list parser
  val many1C : 'a parser -> 'a list parser
  val sepByC : 'a parser -> 'b parser -> 'a list parser
  val sepBy1C : 'a parser -> 'b parser -> 'a list parser
end;

structure Combinators :> COMBINATORS = struct
  open Helpers;
  open Types;

  fun andThen_postfix (p1: 'a parser) (p2: 'b parser) =
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
           Success (r, rs) => firstRes  
         | Failure err => let
            val secondRes = runParser p2 input in
            case secondRes of 
               Failure err => Failure err
             | Success (r,rs) => secondRes
          end
    end in Parser inner
  end;

  fun orElse_postfix_rec (p1: unit -> 'a parser) (p2: unit -> 'a parser) =
    let fun inner input = let
      val firstRes = runParser (p1 ()) input in
        case firstRes of 
           Success (r, rs) => firstRes  
         | Failure err => let
            val secondRes = runParser (p2 ()) input in
            case secondRes of 
               Failure err => Failure err
             | Success (r,rs) => secondRes
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

  fun left_applicative (p1: 'a parser) (p2: 'b parser) = 
  Parser (fn s =>
    let val p1_result = runParser p1 s in
      case p1_result of
          Failure e => Failure e
        | Success (p1_res, rest) => let
          val p2_result = runParser p2 rest in 
            case p2_result of
                Failure e => Failure e
              | Success (_, rest) => Success (p1_res, rest) 
          end
    end
  );

  fun right_applicative (p1: 'a parser) (p2: 'b parser) = 
  Parser (fn s =>
    let val p1_result = runParser p1 s in
      case p1_result of
          Failure e => Failure e 
        | Success (_, rest) =>
            case runParser p2 rest of
               Failure e => Failure e 
             | Success (r, rs) => Success (r, rs)  
    end
  );

  fun bind (p: 'b parser) (f: ('b -> 'a parser)) =
  Parser (fn s =>
    let val p1_result = runParser p s in
      case p1_result of
         Failure e => Failure e
       | Success (r, i) => runParser (f r) i
    end
  );

  fun pass_bind (p1: 'b parser) (p2: 'a parser) : 'a parser =
    bind p1 (fn _ => p2)  

  fun return (a: 'a) : 'a parser = 
    Parser (fn i => Success (a, i));

  fun manyC (p: 'a parser): 'a list parser =
  Parser (fn i =>
    let fun loop input res =
        case runParser p input of
           Success (r, rest) => loop rest (r :: res)
         | Failure _ => (res, input)
        val rest = loop i []
        val (result, r) = rest in
          Success (rev result, r) 
       end
  );


  fun many1C p = mapP_postfix
    (andThen_postfix p (manyC p))
    (fn (pr, mr) => [pr] @ mr);

  fun sepByC p s = 
    (bind (manyC (left_applicative p s)) 
      (fn r => 
        case r of
          [] => Parser (fn i => Success (r, i))
         | _ => mapP_postfix p (fn pr => r @ [pr])))

  fun sepBy1C p s =
    (* TODO:: This must be a bug!
      I don't really sure soo, but
      this implementation looks
      kinda wierd and buggie *)
    mapP_postfix 
      (andThen_postfix 
        (manyC (left_applicative p s))
        p)
      (fn (r, rs) => r @ [rs]);

end;

