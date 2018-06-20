#!/bin/bash

tarOrNot="false"

checkIfTar(){

    if [[ "$1" == *.tar.gz || "$1" == *.tar ]]
    then
        tarOrNot="true"
    else
        tarOrNot="false"
    fi

}

parseDirectory(){

    cd "$3"

    for f in *
    do
        if [ -d "$f" ]
        then
            parseDirectory "$1" "$2" "$f"
        else
            checkIfTar "$f"

            if [ "$tarOrNot" == "true" ]
            then
                parseTar "$1" "$2" "$f"
            fi
        fi
    done

    cd ".."

}

parseTar(){

    tempString="_temp"

    mkdir $3$tempString

    tar xf $3 -C $3$tempString

    cd $3$tempString

    if [ "$2" == "true" ]
    then
        echo "Number of files in tar archive: $3 is $(ls | wc -l)"
    fi

    if [ "$1" == "true" ]
    then
        grep -rnw -e "Such Open, much Stack"
    fi

    for f in *
    do
        if [ -d "$f" ]
        then
            parseDirectory "$1" "$2" "$f"
        else
            checkIfTar "$f"

            if [ "$tarOrNot" == "true" ]
            then
                parseTar "$1" "$2" "$f"
            fi
        fi

    done

    cd ".."

    rm -r $3$tempString
}

checkCommand(){
    local nFlag="false"
    local cFlag="false"
    local isTar="false"
    local isDir="false"

    local int index=-1
    local int parsePosition=0

    for arg in "$@"
    do
        let "index += 1"

        if [ "$arg" == "-n" ]
        then
            nFlag="true"
        elif [ "$arg" == "-c" ]
        then
            cFlag="true"
        elif [ -d "$arg" ]
        then
            isDir="true"
            let parsePosition=$index
        else

            checkIfTar "$arg"

            if [ "$tarOrNot" == "true" ]
            then
                 isTar="true"
                 parsePosition=$index

            fi
        fi
    done

    let "parsePosition += 1"

    if [ "$isDir" == "true" ]
    then
        parseDirectory "$nFlag" "$cFlag" "${!parsePosition}"
    elif [ "$isTar" == "true" ]

    then
        parseTar "$nFlag" "$cFlag" "${!parsePosition}"
    else
        echo "no tar or archive"

    fi
}

checkPermission(){

    if [ $UID -ne "0" ]
    then

        checkCommand "$@"
    else
        echo "Tre sa nu fii root boss"
        exit 1
    fi
}

checkPermission "$@"
