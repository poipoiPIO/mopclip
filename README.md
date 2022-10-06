# Mopclip

_A parser combinator library for humans_

## Example:

### Simple csv parser:
```sml
open Mopclip;

- val cell = (manyC anyCharP) mapP implode;
- val line = cell sepBy (charP #",");
- val csv = line sepBy (charP #"\n");

(* To apply this parser, we'll use runParser function *)
runParser csv "meow,meow\nmeow,nmeow";
- val it = Success ([["meow","meow"],["meow","nmeow"]],"")
```

## API reference:
### Types:
##### pResult:
> datatype 'a pResult = Failure of string | Success of 'a

The result type of parsing application

##### parser type:
> datatype 'a parser = Parser of string -> ('a * string) 

Generalized type of any parser in a library.

### Parsers:
##### charP:
> charP : char -> char parser;

simply parses character, for example: `val eol = charP #"\n";`
##### anyOf:
> anyOf : char list -> char parser;

Simply parses one of the characters in a list

##### digitP:
> digitP : char parser;

Parsing a digit:
```sml
val string_to_parse = "1,2,meow";

runParser digitP string_to_parse;
- val it = Success (#"1",",2,meow")
```

##### stringP:
> stringP : string -> string parser;

Parses string: `val meowP = stringP "meow";`

##### anyCharP:
> anyCharP : char parser

Parsing an alphabet character in any register


### Combinators:
##### errorC:
> errorC : string -> 'a parser -> 'a parser

Adds a label to parser Failure message:
```sml
val string_to_parse = ",2,meow";
val digit_parser_with_error = errorC "Digit" digitP;

runParser digit_parser_with_error string_to_parse;
- val it = Failure "Digit :: Excepted character: 9, But: , was found"

(* let's fail parser without the error label*)
runParser digitP string_to_parse;
- val it = Failure "Excepted character: 9, But: , was found"
```

##### Basic parser combinators:
> infix andThen : 'a parser -> 'b parser -> ('a * 'b) parser

Sequentially run parsers and returns the result of parser application

> infix orElse : 'a parser -> 'a parser -> 'a parser

Run the first parser and if it fails return the result of the second one

##### mapP:
> infix mapP : 'a parser -> ('a -> 'b) -> 'b parser

Applies a function to the parser result and wraps it in parser type

##### manyC:
> manyC : 'a parser -> 'a list parser

Applies parser as many as it succeeds and returns the list of results as the result

```sml
val manyDigits = manyC digitP;
```

> infix many1C : 'a parser -> 'a list parser

It has the same behavior as the `manyC` combinator, but required at least one successful `'a parser` application to parse successefully

##### sepBy:
> infix sepBy : 'a parser -> 'b parser -> 'a list parser

Parses sequence of parsers separated by the parser. For example, you might look in the csv-parser example above.

> infix sepBy1 : 'a parser -> 'b parser -> 'a list parser

It has the same behavior as the `sepBy`, but required at least one sepBy unit to parse successefully

##### Applicatives:
Let's write some parsers using applicative operations!
```sml
- val digitArrayP = 
    ((charP #"[")
      *> (manyC (digitP <* (charP #",")))
      <* (charP #"]"))
      mapP (map (fn c => (ord c) - 48));

runParser digitArrayP "[1,2,3,]";
- val it = Success ([1,2,3],"")
```

> `p1 <* p2` - means that we apply p1, then apply p2, and return the result of p1 and the rest of the parsing 

> `p1 *> p2` - apply the first parser, apply the second parser, and return the result of the second one

##### Monadic operation:
Just a bunch of standard monadic operation needed to combine parsers

> infix >>= : 'a parser -> ('a -> 'b parser) -> 'b parser

> infix >>> : 'a parser -> 'b parser -> 'b parser

