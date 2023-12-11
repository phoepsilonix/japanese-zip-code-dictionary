#!/bin/sh

wget https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
wget https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip

SEEDTXT1=ZIP.CSV
SEEDTXT2=ZIP2.CSV
SRCTXT1=KEN_ALL.CSV
SRCTXT2=JIGYOSYO.CSV
USERDIC=user_dic-japanese-zip-code

unzip ken_all.zip
unzip jigyosyo.zip

PYTHONPATH="$PWD:$PYTHONPATH" python dictionary/gen_zip_code_seed.py --zip_code="${SRCTXT1}" > ${SEEDTXT1}
PYTHONPATH="$PWD:$PYTHONPATH" python dictionary/gen_zip_code_seed.py --jigyosyo="${SRCTXT2}" > ${SEEDTXT2}

ruby user_dict.rb -i user_dic_id.def -f ${SEEDTXT1} > ../${USERDIC}
ruby user_dict.rb -i user_dic_id.def -f ${SEEDTXT2} > ../${USERDIC}2
sed 's|BOS/EOS|地名|' -i ../${USERDIC}
sed 's|BOS/EOS|組織|' -i ../${USERDIC}2
cat ../${USERDIC}2 >> ../${USERDIC}

split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt ../$USERDIC $USERDIC-
rm ../${USERDIC} ../${USERDIC}2

[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz
mkdir -p ../release
tar cf ../release/${USERDIC}.tar ${USERDIC}-*.txt ../LICENSE.user_dic
xz -9 -e ../release/${USERDIC}.tar

rm $SEEDTXT $SEEDTXT2 $SRCTXT1 $SRCTXT2 ken_all.zip jigyosyo.zip $USERDIC-*.txt
