NEED_UPLOAD=$1
TOKEN=$2
FILE=$3

if [[ $NEED_UPLOAD = 1 ]] ; then
echo "fir publish"

fir login -T ${TOKEN}
fir publish ${FILE}
fi
