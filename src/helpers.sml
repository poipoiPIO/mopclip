infix  3 $    fun f $ y = f y
infix  3 |>   fun x |> f = f x
    
structure Helpers = struct
  fun reduce reduction iterable =
    (* Just an helper around the foldr function *)
    let val (first::rest) = iterable in
      foldr (fn (x, y) => reduction x y) first rest
    end;
end;
