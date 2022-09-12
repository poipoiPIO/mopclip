if [ $1 == "--interactive" ]
then
  rlwrap smlnj src/helpers.sml src/types.sml src/combinators.sml src/parsers.sml
else
  mlton -output ./o.out src/mparcomb.mlb 
fi
