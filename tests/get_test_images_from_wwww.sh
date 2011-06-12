
testfile='./input/map01small.jpg'
if [ -f  ${testfile} ]
then
  echo "images already exist, not downloading"
else
  wget http://www.theveganrobot.com/pirateview/katyusha/flare.jpg
  wget http://www.theveganrobot.com/pirateview/katyusha/map01.jpg
  mv flare.jpg ./input/
  mv map01.jpg ./input/
  convert ./input/map01.jpg -resize 1024x1024 ./input/map01small.jpg
fi


