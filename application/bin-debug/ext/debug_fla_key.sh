#!/bin/bash
echo "$(basename $0) $*"
here=$(dirname $0)

inPath=''

outPath='D:/workspace/monster-debugger/application/src/libs/temp'
Verbose=""
usage()
{
	echo "usage: $(basename $0) -i path -o path"
	echo "	or:$(basename $0) -f fileList -o path"
	echo '-i: a path contains fla'
	echo '-f: read list of source-file names from FILE'
	exit 1
}

while getopts i:o:f:v:h OPTION
do
	case ${OPTION} in
		i) inPath=$OPTARG;;
		o) outPath=$(win $OPTARG);;
		f) fileList=$OPTARG;;
		v) Verbose="-v";;

		:) usage;;
		?) usage;;
	esac
done


resolve(){
	cd $1
	eval echo \"\$$2\" | xargs cygpath -am
	cd - > /dev/null
}
if [[ -d $inPath && -n $outPath ]]; then
	if [[ -f "$fileList" ]]; then
		flaFiles=$(cat $fileList)
	else
		cd $inPath
		flaFiles=$(find . -name "*.fla" )
		cd - > /dev/null
	fi

	if [[ "$flaFiles" == "" ]]; then
		echo -e 'cannot find any *.fla file. Exit.'
		exit 1;
	fi


	flaFiles=$(resolve $inPath flaFiles)


else
	echo "error: unsupported now." >&2
	exit 1

fi


echo "flaFiles=
$flaFiles"
echo '======================='

[[ -z "$flaFiles" ]] && exit 1
[[ -d "$outPath" ]] || mkdir -p $outPath
emptydir $outPath
$here/run_jsfl $here/debug_fla_key.jsfl $Verbose -l "find" -l "$outPath" -l "$flaFiles"
