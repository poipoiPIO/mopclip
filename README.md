<h2 align="center">
    <a href="https://github.com/poipoiPIO/mopclip" target="blank_">
        <img height="150" alt="Mopclip" src="https://raw.githubusercontent.com/poipoiPIO/mopclip/master/res/New Projectqw.svg" />
    </a>
    <br>
    Mopclip : human-friendly monadic parser-combinator library
</h2>

## Example:

### Simple csv parser:
```sml
open Mopclip;

val cell = (manyC anyCharP) mapP implode;
val line = cell sepBy (charP #",");
val csv = line sepBy (charP #"\n");

(* To apply this parser, we'll use runParser function *)
runParser csv "meow,meow\nmeow,nmeow";
- val it = Success ([["meow","meow"],["meow","nmeow"]],"")
```

## Overview of MLB files

- `lib/github.com/poipoiPIO/mopclip/mopclip.mlb`:

  - **signature** [`Mopclip`](lib/github.com/poipoiPIO/mopclip/lib.sml)

## Use of the package

This library is set up to work well with the SML package manager
[smlpkg](https://github.com/diku-dk/smlpkg).  To use the package, in
the root of your project directory, execute the command:

```
$ smlpkg add github.com/poipoiPIO/mopclip
```
And then sync your packages locally using the following command:

```
$ smlpkg sync
```

You can now reference the `mlb`-file using relative paths from within
your project's `mlb`-files.

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

Simply parse one of the characters in a list

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

Parse an alphabet character in any register


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

> infix orElseL : (unit -> 'a parser) -> (unit -> 'a parser) -> 'a parser

Run the first parser and if it fails return the result of the second one
Similar to orElse parser, but uses arguments wrapped in the lambda abstraction for
lazy-semantics needed for combinators recursion.

##### mapP:
> infix mapP : 'a parser -> ('a -> 'b) -> 'b parser

Applies a function to the parser result and wraps it in parser type

##### manyC:
> manyC : 'a parser -> 'a list parser

Applies parser as many as it succeeds and returns the list of results as the result

```sml
val manyDigits = manyC digitP;
```

> many1C : 'a parser -> 'a list parser

It has the same behavior as the `manyC` combinator, but required at least one successful `'a parser` application to parse successefully

##### sepBy:
> infix sepBy : 'a parser -> 'b parser -> 'a list parser

Parse sequence of parsers separated by the parser. As the demo, you might look in the csv-parser example above.

> infix sepBy1 : 'a parser -> 'b parser -> 'a list parser

It has the same behavior as the `sepBy`, but required at least one sepBy unit to parse successfully

##### Applicatives:
Let's write some parsers using applicative operations!
```sml
- val digitArrayP = 
    ((charP #"[")
      *> (manyC (digitP <* (charP #",")))
      <* (charP #"]"))
      mapP (map (fn c => (ord c) - 48));


##### Applicatives:
runParser digitArrayP "[1,2,3,]";
- val it = Success ([1,2,3],"")
```

> `p1 <* p2` - means that we apply p1, then apply p2, and return the result of p1 and the rest of the parsing 

> `p1 *> p2` - apply the first parser, apply the second parser, and return the result of the second one

##### Monadic operations:
Just a bunch of standard monadic operations needed to combine parsers

> infix >>= : 'a parser -> ('a -> 'b parser) -> 'b parser

> infix >>> : 'a parser -> 'b parser -> 'b parser


##### Simple interpreter using Mopclip:
https://gist.github.com/poipoiPIO/e202cba9d08dfa4d7a3b9556384950ee
