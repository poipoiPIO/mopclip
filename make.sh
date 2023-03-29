LIB=lib/github.com/poipoiPIO/mopclip 

if [ $1 == "-i" ]
then
  rlwrap smlnj $LIB/helpers.sml $LIB/types.sml $LIB/combinators.sml $LIB/parsers.sml $LIB/lib.sml 
fi

if [ $1 == "--mlton" ] 
then
  mlton -output ./mopclip.out $LIB/mopclip.mlb 
fi
