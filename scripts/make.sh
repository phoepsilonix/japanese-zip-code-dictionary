#!/bin/sh

wget -nc https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
wget -nc https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip

SEEDTXT1=ZIP.CSV
SEEDTXT2=ZIP2.CSV
SRCTXT1=KEN_ALL.CSV
SRCTXT2=JIGYOSYO.CSV
USERDIC=user_dic-japanese-zip-code
USERDIC1=user_dic-japanese-zip-code-ken
USERDIC2=user_dic-japanese-zip-code-jigyosyo

unzip -o ken_all.zip
unzip -o jigyosyo.zip

PYTHONPATH="$PWD:$PYTHONPATH" python dictionary/gen_zip_code_seed.py --zip_code="${SRCTXT1}" > ${SEEDTXT1}
PYTHONPATH="$PWD:$PYTHONPATH" python dictionary/gen_zip_code_seed.py --jigyosyo="${SRCTXT2}" > ${SEEDTXT2}

awk 'BEGIN{FS="\t"}!a[$0]++{print $1 "\t" $5 "\t" "地名" "\t"}' ${SEEDTXT1} > ../${USERDIC1}
awk 'BEGIN{FS="\t"}!a[$0]++{print $1 "\t" $5 "\t" "組織" "\t"}' ${SEEDTXT2} > ../${USERDIC2}

split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt ../${USERDIC1} ${USERDIC1}-
split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt ../${USERDIC2} ${USERDIC2}-
rm ../${USERDIC1} ../${USERDIC2}

[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz
mkdir -p ../release
tar cf ../release/${USERDIC}.tar ${USERDIC1}-*.txt ${USERDIC2}-*.txt ../LICENSE.user_dic
xz -9 -e ../release/${USERDIC}.tar

rm $SEEDTXT1 $SEEDTXT2 $SRCTXT1 $SRCTXT2 ken_all.zip jigyosyo.zip ${USERDIC1}-*.txt ${USERDIC2}-*.txt
