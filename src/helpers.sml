infix  3 $    fun f $ y = f y
infix  3 |>   fun x |> f = f x
    
structure Helpers = struct
  exception EmptyList;

  fun reduce foo seq =
    case seq of
      nil => raise EmptyList   
    | [a] => a 
    | x::xs => foo x (reduce foo xs);


  fun flat xs = List.foldr op@ [] xs;
end;
