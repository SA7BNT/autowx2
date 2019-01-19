#
# moving recorded images to the appropriate final dir
#
# mv $rawImageDir/*.jpg $imgdir/
# fileNameCore="20190118-1012_METEOR-M2"


outHtml="$imgdir/$fileNameCore.html"  # html for this single pass
indexHtml="$imgdir/index.html"        # main index file for a given day
htmlTemplate="$wwwDir/index.tpl"


# ---single gallery preparation------------------------------------------------#

makethumb() {
    obrazek="$1"
    local thumbnail=$(basename "$obrazek" .jpg)".th.jpg"
    convert -define jpeg:size=200x200 "$obrazek" -thumbnail '200x200^' granite: +swap -gravity center -extent 200x200 -composite -quality 82 "$thumbnail"
    echo "$thumbnail"
    }

# -----------------------------------------------------------------------------#

logFile="$rawImageDir/$fileNameCore.log"   # log file to read from

varDate=$(sed '1q;d' $logFile)
varSat=$(sed '3q;d' $logFile)
varStart=$(sed '4q;d' $logFile) # unused
varDur=$(sed '5q;d' $logFile)
varPeak=$(sed '6q;d' $logFile)
varFreq=$(sed '7q;d' $logFile)

dateTime=$(date -d @$varStart +"%Y-%m-%d")
dateTimeDir=$(date -d @$varStart +"%Y/%m/%d")  # directory format of date, eg. 2018/11/22/
wwwPath=$wwwRootPath/recordings/meteor/img/$dateTimeDir

echo $wwwPath/$fileNameCore > $wwwDir/meteor-last-recording.tmp


# -----------------------------------------------------------------------------#


cd $rawImageDir

#
# should we resize images?
#

if [ "$resizeimageto" != "" ]; then
  echo "Resizing images to $resizeimageto px"
  mogrify -resize ${resizeimageto}x${resizeimageto}\> *.jpg
fi

#
# loop over images and generate thumbnails
#

for obrazek in *.jpg
do
		echo $obrazek
		base=$(basename $obrazek .jpg)
    sizeof=$(du -sh "$obrazek" | cut -f 1)
    # generate thumbnail
    thumbnail=$(makethumb "$obrazek")
		echo $thumbnail
    echo "<a data-fancybox='gallery' data-caption='$varSat | $varDate | $enchancement ($sizeof)' href='$wwwPath/$obrazek'><img src='$wwwPath/$thumbnail' alt='$enchancement' title='$enchancement | $sizeof' class='img-thumbnail' /></a> " >> $outHtml
done




#
# move images to their destination
#

mv $rawImageDir/* $imgdir/
# cp $rawImageDir/* $imgdir/


# ----consolidate data from the given day ------------------------------------#
# generates neither headers nor footer of the html file

echo "" > $indexHtml.tmp
for htmlfile in $(ls $imgdir/*.html | grep -v "index.html")
do
  cat $htmlfile >> $indexHtml.tmp
done

# ---------- generates pages according to the template file -------------------

currentDate=$(date)
echo $currentDate

htmlTitle="METEOR-M2 images | $dateTime"
htmlBody=$(cat $indexHtml.tmp)

source $htmlTemplate > $indexHtml
