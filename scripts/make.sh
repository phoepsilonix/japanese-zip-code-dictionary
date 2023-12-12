#!/bin/sh

wget -nc https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
wget -nc https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip

SEEDTXT1=ZIP.CSV
SEEDTXT2=ZIP2.CSV
SRCTXT1=KEN_ALL.CSV
SRCTXT2=JIGYOSYO.CSV
USERDIC=user_dic-japanese-zip-code

unzip -o ken_all.zip
unzip -o jigyosyo.zip

PYTHONPATH="$PWD:$PYTHONPATH" python dictionary/gen_zip_code_seed.py --zip_code="${SRCTXT1}" > ${SEEDTXT1}
PYTHONPATH="$PWD:$PYTHONPATH" python dictionary/gen_zip_code_seed.py --jigyosyo="${SRCTXT2}" > ${SEEDTXT2}

cat ${SEEDTXT1} |awk 'BEGIN{FS="\t"}!a[$0]++{print $1 "\t" $5 "\t" "地名" "\t"}' > ../${USERDIC}
cat ${SEEDTXT2} |awk 'BEGIN{FS="\t"}!a[$0]++{print $1 "\t" $5 "\t" "組織" "\t"}' >> ../${USERDIC}

split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt ../$USERDIC $USERDIC-
rm ../${USERDIC}

[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz
mkdir -p ../release
tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt ../LICENSE.user_dic
xz -9 -e ../release/${USERDIC}.tar

rm $SEEDTXT $SEEDTXT2 $SRCTXT1 $SRCTXT2 ken_all.zip jigyosyo.zip $USERDIC-*.txt
