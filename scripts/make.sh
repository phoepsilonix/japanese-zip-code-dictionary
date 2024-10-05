#!/bin/sh

wget -nc https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
wget -nc https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip
sha256sum --check ../last_checksum.txt
FLAG=$?
echo $FLAG
if [[ "$FLAG" == "0" ]];then
  echo "same checksum."
  exit 1
	else
  echo "checksum changed."
fi

SEEDTXT1=ZIP.CSV
SEEDTXT2=ZIP2.CSV
SRCTXT1=KEN_ALL.CSV
SRCTXT2=JIGYOSYO.CSV
USERDIC=user_dic-japanese-zip-code
USERDIC1=user_dic-japanese-zip-code-ken
USERDIC2=user_dic-japanese-zip-code-jigyosyo

unzip -o ken_all.zip
unzip -o jigyosyo.zip

uconv -x '::[ [:^Katakana:] & [:^Hiragana:] & [:^Han:] & [^ー・「」、，（）]] Fullwidth-Halfwidth; ::[\p{Nl}] Latin-ASCII;' -f cp932 -t UTF-8 ${SRCTXT1} > ${SEEDTXT1}
uconv -x '::[ [:^Katakana:] & [:^Hiragana:] & [:^Han:] & [^ー・「」、，（）]] Fullwidth-Halfwidth; ::[\p{Nl}] Latin-ASCII;' -f cp932 -t UTF-8 ${SRCTXT2} > ${SEEDTXT2}
awk -f ken_all-convert-mozc-dictionary.awk ${SEEDTXT1} > ../${USERDIC1}
awk -f jigyosyo-convert-mozc-dictionary.awk ${SEEDTXT2} > ../${USERDIC2}

split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt ../${USERDIC1} ${USERDIC1}-
split --numeric-suffixes=1 -l 1000000 --additional-suffix=.txt ../${USERDIC2} ${USERDIC2}-
rm ../${USERDIC1} ../${USERDIC2}

[[ -e ../release/${USERDIC}.tar.xz ]] && rm ../release/${USERDIC}.tar.xz
mkdir -p ../release
tar cf ../release/${USERDIC}.tar ${USERDIC1}-*.txt ${USERDIC2}-*.txt ../LICENSE.user_dic
xz -9 -e ../release/${USERDIC}.tar

sha256sum ken_all.zip jigyosyo.zip > ../last_checksum.txt
rm $SEEDTXT1 $SEEDTXT2 $SRCTXT1 $SRCTXT2 ken_all.zip jigyosyo.zip ${USERDIC1}-*.txt ${USERDIC2}-*.txt
exit 0
