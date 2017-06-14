filename=$1
outfile=${filename%.svg}.pdf
temp="/tmp/tmp.svg"
grep -Ev '>Flame Graph</text>|#background' $filename > $temp
inkscape $temp --export-pdf=$outfile
