structure Combinators = struct
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

  fun manyC (p: 'a parser): 'a list parser = Parser (fn i =>
  let val xs = ref []
      fun loop input =
        case runParser p input of
           Success (r, rest) => ( 
             xs := r :: !xs;
             loop rest
           )
         | Failure _ => input
      val rest = loop i in
        Success (rev (!xs), rest) 
     end
  );


  infix mapP    fun p1 mapP p2 = mapP_postfix p1 p2;
  infix orElse  fun p1 orElse p2 = orElse_postfix p1 p2;
  infix andThen fun p1 andThen p2 = andThen_postfix p1 p2;
  infix *>      fun p1 *> p2 = right_applicative p1 p2;
  infix <*      fun p1 <* p2 = left_applicative p1 p2;
end;

