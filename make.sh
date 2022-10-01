if [ $1 == "--interactive" ]
then
  rlwrap smlnj src/helpers.sml src/types.sml src/combinators.sml src/parsers.sml src/lib.sml
fi

if [ $1 == "--mlb" ] 
then
  ./third-party/sml-buildscripts/smlrepl src/mparcomb.mlb
else
  mlton -output ./o.out src/mparcomb.mlb 
fi
