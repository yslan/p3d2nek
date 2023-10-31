in=$1
fname="${in%.*}"
out=$fname.rea

echo $in,$out

dir=`dirname "$0"`
cat $dir"/dummy2d.rea.head" > $out
cat $in >>$out
cat $dir"/dummy2d.rea.tail" >> $out

