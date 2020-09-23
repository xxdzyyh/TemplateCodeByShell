#typedef NS_ENUM(NSUInteger,MyTeamCellType) {
#    MyTeamCellTypeOne,
#    MyTeamCellCount
#};

alias gnu-sed="/usr/local/opt/gnu-sed/libexec/gnubin/sed"


# MyTeamCellType
enumName=$(grep 'typedef NS_ENUM' $1 | gnu-sed 's/.*,\(.*\)).*/\1/g')
# MyTeam
prefix=`echo $enumName | gnu-sed 's/CellType//'`

enumValues=$(awk -F "," 'BEGIN {
	enumValues="";
} { 
	if (match($1,"'$prefix'")) {
		# 去掉 $1 前面的空格
		sub("^ *","",$1);
		enumValue=$1;
		sub(".*CellType","",enumValue);
		enumValues=enumValues""$1" ";

	}
} END {
	print enumValues;
}' $1)

echo $enumValues

result="switch (<#indexPath.row#>) {\n"

for i in ${enumValues[*]}; do
result=$result"\n\t\tcase $i: {\n\n
\t\t}\n\t\t\tbreak;"
done

echo $result
