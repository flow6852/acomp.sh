#!/bin/bash

INTERVAL=1
FILE=$1
CONFIG=$HOME/.config/acomp/

#-h text
function HELPCMD(){
    echo "USAGE"
    echo "  .auto_compiler <source file>"
    echo " or"
    echo "  .auto_compiler"
    echo "  (if you forget input source file.)"
    echo "OPTHIONS"
    echo "   -h: show help"
    echo "PURPOSE"
    echo "   This command can compile automatically that you input good source file."
    echo "   This has compile command above default."
    echo "     make"
    echo "     gcc -o (basename without source file) (source file)"
    echo "     java (source file)"
    echo "     platex (source file) ; platex (source file) ; dvipdfmx (basename source file).dvi"
    echo "     rustc (source file)"
    echo "   If you want to compile other language, you have to write in this scripts file."
}

#read source file and check about extend and existing
function READFILE(){
    if [ -z "$FILE" ] ; then
	echo "Please input your program file"
	read FILE
    fi
    EXT=${FILE##*.}
    FILENAME=`basename $FILE`
    DIRNAME=`dirname $FILE`
    if [ "$DIRNAME" == "." ] ; then
	FULL=`pwd`/${FILENAME}
	EXEFILE=`pwd`/${FILENAME%.*}
    else
	FULL=`pwd`/${DIRNAME}/${FILENAME}
	EXEFILE=`pwd`/${DIRNAME}/${FILENAME%.*}
    fi
    check="s"
    if [ ! -e "$FULL" ] ; then
	echo "This file doesn't exist."
	ans="0"
	echo "\"$FILE\":Do you edit new file?(y/n)"
	read ans
	if [ "$ans" == "n" ] ; then
	    exit 1
	fi
	check="0"
    fi
}

#This line is compile command and execution command.

function USEGUI(){
	GUIPID=`ps -ef | grep "$1 $2" | grep -v grep | awk '{print $2}'`
	if [ "$GUIPID" != "" ] ; then
		kill -15 $GUIPID &> /dev/null &
	fi
	fviewerprocess=`ps --no-heading -C $1 -o pid`
	$1 $2 2>&1> /dev/null &
	bviewerprocess=`ps --no-heading -C $1 -o pid`
	GUIPID=$(join -v 1 <(echo "$bviewerprocess") <(echo "$fviewerprocess"))
}

function FINCMD(){
    if [ -n "$GUIPID" ] ; then
	kill -15 $GUIPID 
    fi
}


#conf->command,execution.
function INDIRECTEXPANTION(){
	RETTMP=$(cat $CONFIG/$1 | grep $2)
	RETTMPS=$(echo ${RETTMP#*=})
	ARG3=$3
	TMP3='$ARG3'
	echo $(eval echo ${RETTMPS//"filename"/$TMP3})
}


#you have to input compiler to need for you.
function EXECUTE (){
	for i in $(ls -1 $CONFIG) ; do
		if [[ $EXT = ${i%.*} ]] ; then
			TMP=`INDIRECTEXPANTION $i "command" ${FILENAME%.*}`
			COMMAND=$(echo ${TMP})
			TMP=`INDIRECTEXPANTION $i "command" ${FILENAME%.*}`
			COMMANDSTR=$(echo ${TMP})
			TMP=`INDIRECTEXPANTION $i "execution" ${FILENAME%.*}`
			EXE=$(echo ${TMP})
		fi
	done
    if [ -e "Makefile" ] ; then
	COMMAND="make"
	COMMANDSTR="make"
    fi
    echo "$COMMANDSTR"
}

# check command and read to input argument and redirection fileecho "start."
function CHECKCMD(){
    echo "Do you want to check command?(Y/n)"
    read answer
    if [ "$answer" != "n" ] ; then
	if [ "$EXESTR" != "" ] ; then 
		echo "If you change running command, please input now:\"$EXESTR\""
	else
		echo "If you change running command, please input now:\"$EXE\""
	fi
	read RUNCMD
	if [ -n "$RUNCMD" ] ; then
	    EXE=$RUNCMD
	    EXESTR=$RUNCMD
	fi
	echo "Please input argument."
	read ARGUMENT
	echo "Please input redirection file."
	read TEXT
	if [ -n "$TEXT" ] ; then
	    TEXTNAME=`basename $TEXT`
	    DIRTEXT=`dirname $TEXT`
	    FULLTEXT=`pwd`/${DIRTEXT}/${TEXTNAME}
	fi
    fi
}

#editor
function STARTEDITOR(){
	if [ "$EDITOR" == "emacs" ] ; then
		touch $FULL
    		pid=`ps -ef | grep "$EDITOR $FILE" | grep -v grep | awk '{print $2}'`
    		if [ -z "$pid" ] ; then
			fprocess=`ps --no-heading -C $EDITOR -o pid`
			$EDITOR $FULL &
			bprocess=`ps --no-heading -C $EDITOR -o pid`
			pid=$(join -v 1 <(echo "$bprocess") <(echo "$fprocess"))
   		fi
		before=`ls --full-time $FULL | awk '{print $6" - "$7}'`
	fi
	if [ "$EDITOR" == "vim" ] ; then
		touch $FULL
    		pid=`ps -ef | grep "$EDITOR $FILE" | grep -v grep | awk '{print $2}'`
    		if [ -z "$pid" ] ; then
			fprocess=`ps --no-heading -C xterm -o pid`
			$TERM -bg black -fg white -e vim $FULL &
			bprocess=`ps --no-heading -C xterm -o pid`
			pid=$(join -v 1 <(echo "$bprocess") <(echo "$fprocess"))
   		fi
		before=`ls --full-time $FULL | awk '{print $6" - "$7}'`
	fi
}

#loop
function EXECHECK(){
    if [ "$answer" != "n" ] ; then
	if [ -n "$FULLTEXT" ] ; then
	    if [ -n "$ARGUMENT" ] ; then
		echo "execution"
		$EXE $ARGUMENT < $FULLTEXT
	    else
		echo "execution"
		$EXE < $FULLTEXT
	    fi
	else
	    if [ -n "$ARGUMENT" ] ; then
		echo "execution"
		$EXE $ARGUMENT
	    else
		echo "execution"
		$EXE
	    fi
	fi
    fi
}

function LOOPSUB(){
    now=`ls --full-time $FULL | awk '{print $6" - "$7}'`
    if [ "$now" != "$before" ] ; then
	echo "compile"
	$COMMAND
	comp=$?
	echo "$comp"
	if [ "$comp" == "0" ] ; then
	    EXECHECK
	fi
	before=$now
    fi
}

function LOOPCMP(){
    while [ -n "$pid" ] 
    do
	if [ "$check" != "s" ] ; then
	    echo "If you input \"s\", start compile"
	    read check
	fi
	LOOPSUB
	sleep $INTERVAL
	pid=`ps -p $pid --no-heading | grep -v grep | awk '{print $1}'`
    done
}

function LAST(){
    echo "last"
    if  [ ! -e "$EXEFILE" ] ; then
	if [ "$check" != "s" ] ; then
	    echo "rm $FILE"
	    rm $FILE
	    echo "finish"
	    return
	fi
    fi
    if [ "$answer" == "n" ] ; then
	CHECKCMD
   fi
    EXECHECK
    FINCMD
    echo "finish."
}


#main
if [ "$1" == "-h" ] ; then
    HELPCMD
    exit 0
fi
READFILE
EXECUTE
CHECKCMD
STARTEDITOR #before setting
LOOPCMP #diff now before
LAST
exit 0
