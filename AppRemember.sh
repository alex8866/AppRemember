#!/bin/bash
#okular "$1"

#For you to configure

AppNameConf=$HOME/bin/AppRemember.conf
AppFilePath="$HOME/bin"


function usage()
{
    :
}

function get_open()
{
    :
}

function parse_file()
{
    local AppNameConf="$1"
    local GetFiled="$2"
    local GetNumber="$3"

    cat "$1" | sed '/^#/d;/^$/d' | awk -v NUM="$GetFiled" '
    BEGIN {
    RS = "<AppName>"
    FS= "\n"
    }
    {
        #gsub(/[[:blank:]]*/, "", $(NUM));
        gsub(/[[:blank:]]*$/,"",$(NUM));
        gsub(/^[[:blank:]]*/,"",$(NUM))

        print $(NUM)
    }' |sed '/^$/d' | eval sed -n '${GetNumber}p' |awk -F= '{print $2}'
}

function create_app_file()
{
    AppFileName="$1"
    AppOriginName="$2"
    AppLogPath="$3"
    AppNameConf="$4"

    cat << 'EOF' > "$AppFilePath/$AppFileName"
#!/bin/bash

MyName=AppOriginName


function sort_file()
{
    cat "AppLogPath" | sort|uniq > /tmp/AppOriginName.txt

    NR=$(cat AppNameConf | awk -F= -v JUG="$MyName" '{
        if ($2 == JUG)
            {
                print NR
            }
    }'
    )
    NR=$((NR + 3))

    cat AppNameConf | eval sed -n '${NR}p' | awk -F= '{print $2}'| \
        awk 'BEGIN {RS=";"}{print $0}' | sed '/^$/d' > /tmp/AppOriginName_tmp.txt


    for file in $(cat /tmp/AppOriginName.txt)
    do
        grep "$file" /tmp/AppOriginName_tmp.txt &>/dev/null && continue
        echo "$file" >> /tmp/AppOriginName_tmp.txt
    done
    mv -f /tmp/AppOriginName_tmp.txt AppLogPath
}

function deal_file()
{
    local filename="$1"
    filename=$(readlink -f "$1")
    [ -e "$filename" ] || {
        echo 1 
        return 1
    }

    echo "$filename" >> "AppLogPath"
    sort_file
    echo "$filename"
}

function AppL()
{
    clear

    [ ! -f "AppLogPath" ] && touch "AppLogPath"
    sort_file
    line=$(cat -n "AppLogPath")
    echo -e "$line"
    echo
    echo "Which document?[0-9q]"
    printf "RowNumber: "
    
    read answer
    #jug="$(printf "$answer" |tr -d [0-9])"
    #if [ "$jug" == "" ];then
    filename=$(sed -n "$answer""p" "AppLogPath" | cut -f2)
    filename="$(deal_file "$filename")"
    [ "$filename" != "1" ] && AppOriginName "$filename" &>/dev/null &
    #else
    #    exit
    #fi
}
#[ "$1" == "-l" ] && AppL

#: << EOF
while getopts lp opt
do
    case $opt in
        l)
            AppL
            exit
            ;;
    esac
done
filename="$(deal_file "$1")"
AppOriginName "$filename" &>/dev/null &

EOF
}

count=1
for AppFileName in $(parse_file "$AppNameConf" 3)
do
    #create_app_file $AppFileName $AppOriginName $AppLogPath $AppNameConf
    #create_app_file ok okular /home/aaron/bin/need-save/okular.txt "1"
    #AppFileName="$(parse_file $AppNameConf 3)"
    AppOriginName="$(parse_file $AppNameConf 2 $count)"
    AppLogPath="$(parse_file $AppNameConf 4 $count)"
    AppShowOpen="$(parse_file $AppNameConf 5 $count)"

    create_app_file "$AppFileName" "$AppOriginName" "$AppLogPath" "$AppNameConf"
    cat /dev/null > "$AppLogPath"

    #echo "$AppFileName" "$AppOriginName" "$AppLogPath" "$AppShowOpen"
    #replace strings
    eval sed -i 's/AppOriginName/${AppOriginName}/g' "$AppFilePath/$AppFileName"
    eval sed -i 's%AppLogPath%"${AppLogPath}"%g' "$AppFilePath/$AppFileName"
    eval sed -i 's%AppNameConf%"${AppNameConf}"%' "$AppFilePath/$AppFileName"
    chmod +x "$AppFilePath/$AppFileName"
    ((count++))
done
