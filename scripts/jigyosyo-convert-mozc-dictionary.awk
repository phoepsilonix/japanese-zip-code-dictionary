BEGIN{
    FS=","
    f=0
}
{
    gsub( "\"", "", $0 );
    gsub(/以下に掲載がない場合|.*くる場合|.*村一円/,"",$9);
    if (f==$8) {
        next;
    } else
    {
        f=0
    }
    if (($7 ~ /（.+、/ || $7 ~ /（.*・/) && f==0) f = $8;
}
{
    gsub("，",",",$3)
    gsub("（","(",$3)
    gsub("）",")",$3)
    gsub("㈱","(株)",$3)
    if (!a[$8,$4,$5,$6,$3]++) {
        print substr($8, 1, 3) "-" substr($8,4,4) "\t" $4 $5 $6 " " $3 "\t" "組織" "\t"
    }
}
