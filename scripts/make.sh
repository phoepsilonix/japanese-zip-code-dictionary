#!/bin/sh

wget https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
wget https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip

SRCTXT=ZIP.CSV
SRCTXT1=KEN_ALL.CSV
SRCTXT2=JIGYOSYO.CSV
USERDIC=user_dic-japanese-zip-code

unzip ken_all.zip
unzip jigyosyo.zip

PYTHONPATH="$PWD:$PYTHONPATH" python dictionary/gen_zip_code_seed.py --zip_code="KEN_ALL.CSV" --jigyosyo="JIGYOSYO.CSV" > ${SRCTXT}

ruby user_dict.rb -i user_dic_id.def -f ${SRCTXT} > ../${USERDIC}

split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt ../$USERDIC $USERDIC-
rm ../$USERDIC

[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz

tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt ../LICENSE.user_dic
xz -9 -e ../release/${USERDIC}.tar

rm $SRCTXT $SRCTXT1 $SRCTXT2 ken_all.zip jigyosyo.zip $USERDIC-*.txt
