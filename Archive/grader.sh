#!/usr/bin/env bash

function msg() {
  local OPTIND=1
  local OPTARG
  local color
  local indent
  local length
  local nxtmsg
  while getopts "c:i:l:" arg; do
    case $arg in
      c)
        color="$OPTARG"
        ;;
      i)
        indent="$OPTARG"
        ;;
      l)
        length="$OPTARG"
        ;;
    esac
  done
  : ${color:=6}
  : ${indent:=0}
  : ${length:=96}

  tput setaf $color
  tput bold

  msg="${@:$OPTIND:$#}"
  fold -w $((length-indent)) <<< "$msg" | sed 's/^/'"$(printf %${indent}s)"'/'
  
  tput sgr0
}

function ag() {
  local logfile
  logfile=$1
  shift
tclsh <(cat <<__EOF__
package require Expect

set stty_init "-opost"
set timeout -1
eval [list spawn -noecho] timeout -s 9 --preserve-status 10 \$argv
expect
set result [wait]
if { [llength \$result] == 4 } {
    puts [open "$workdir/ag_log" "w"] "Exited [lindex \$result 3]"
    exit [lindex \$result 3]
} else {
    puts [open "$workdir/ag_log" "w"] "Signaled [lindex \$result 5]"
    exit 1
}
__EOF__
) ${1+"$@"}
}

function pscore() {
  msg -i 2 "Total: $score/$total ($tscore/$pts)"
}


function ccrash() {
  if [[ "$disp" == "Signaled" ]]
  then
    crashed=1
  fi
}


  src="$1"
  archive="$(mktemp -d)/archive"
  sample="/scratch/archive_examples/archive"
  outputdir="$(mktemp -d)"
  inputdir="$(mktemp -d)"
  workdir="$(mktemp -d)"
  (
    score=0
    total=0
    tn=0
    crashed=0

    echo
    cmd=(gcc -std=c99 -o "$archive" "$src")
    msg "Compiling Program"
    msg -i 2 -c 3 "${cmd[@]}"
    ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
    read disp status <"$workdir/ag_log"
    if [[ "$disp" == "Exited" && "$status" == "0" ]]
    then
      msg -i 2 -c 2 "COMPILATION SUCCEEDED ($disp: $status)"
    else
      sed 's/^/  | /' "$workdir/ag_out"
      msg -i 2 -c 1 "COMPILATION FAILED (Submission could not be graded) ($disp: $status)"
      exit 0
    fi
    
    # GCC WITH FLAGS
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Compiling with flags ($pts points)"
    msg -i 2 -c 3 "${cmd[@]}"
    ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
    read disp status <"$workdir/ag_log"
    if [[ "$disp" == "Exited" && "$status" == "0" ]]
    cmd=(gcc -std=c99 -Wall -Wextra -Wpedantic -Werror -o "$archive" "$src")
    then
      msg -i 2 -c 2 "COMPILATION SUCCEEDED ($disp: $status)"
      ((tscore = pts))
    else
      sed 's/^/  | /' "$workdir/ag_out"
      msg -i 2 -c 1 "COMPILATION FAILED ($disp: $status)"
    fi
    ((total += pts))
    ((score += tscore))
    pscore
    

    # VALGRIND 
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Valgrind test ($pts points)"
    
    cd "$inputdir"
    find "$inputdir" -mindepth 1 -maxdepth 1 -exec rm -rf {} \+
    msg -i 2 "Creating test setup"
    mkdir -p test/dir/
    echo "300:hello 7: 20: world!" >test/dir/file
    touch empty
    tput setaf 58; tree -F . | sed 's/^/    | /'; tput sgr0
    
    msg -i 2  "Testing packing:"
    cmd=(valgrind --error-exitcode=1 --leak-check=full --show-reachable=yes
      --errors-for-leak-kinds=all "$archive" * test.arch)
    msg -i 4 -c 3 "${cmd[@]}"
    ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
    read disp status <"$workdir/ag_log"
    ccrash
  
    if [[ $disp == "Exited" && "$status" == "0" ]]
    then
      msg -i 2 -c 2 "Packing test passed! ($disp: $status)"
      echo
      msg -i 2 "Creating test archive:"
      rm test.arch
      timeout 5 "$sample" * test.arch &>/dev/null
      tput setaf 58; sed 's/^/    | /' test.arch; tput sgr0
      echo

      msg -i 2 "Testing Unpacking:"

      cmd=(valgrind --error-exitcode=1 --leak-check=full --show-reachable=yes
        --errors-for-leak-kinds=all "$archive" test.arch)
      msg -i 2 -c 3 "${cmd[@]}"
      ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
      read disp status <"$workdir/ag_log"
      ccrash
      if [[ "$disp" == "Exited" && "$status" == "0" ]]
      then
        msg -i 2 -c 2 "Unpacking test passed! ($disp: $status)"
        msg -i 2 -c 2 "Both tests passed!"
        ((tscore += pts))
      else
        sed 's/^/    | /' "$workdir/ag_out"
        msg -i 2 -c 1 "Valgrind found errors on unpacking. ($disp: $status)"
      fi
    else
      sed 's/^/    | /' "$workdir/ag_out"
      msg -i 2 -c 1 "Valgrind found errors on packing. ($disp: $status)"
    fi
    ((total += pts))
    ((score += tscore))
    pscore

    # ERROR ON INVALID FILE NAME
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Error on invalid (empty) filename ($pts points)"
    cmd=("$archive" '')
    msg -i 2 -c 3 "${cmd[@]} ''"
    ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
    read disp status <"$workdir/ag_log"
    ccrash
    if [[ "$disp" == "Exited" && "$status" != "0" ]]
    then
      msg -i 2 -c 2 "Test passed! ($disp: $status)"
      ((tscore+=pts))
    else
      sed 's/^/  | /' "$workdir/ag_out"
      msg -i 2 -c 1 "Test failed. ($disp: $status)"
    fi
    ((total += pts))
    ((score += tscore))
    pscore

    
    # ERROR IF NO ARGUMENTS
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Error if no arguments ($pts points)"
    cmd=("$archive")
    msg -i 2 -c 3 "${cmd[@]}"
    ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
    read disp status <"$workdir/ag_log"
    ccrash
    if [[ "$disp" == "Exited" && "$status" != "0" ]]
    then
      msg -i 2 -c 2 "Test passed! ($disp: $status)"
      ((tscore+=pts))
    else
      sed 's/^/  | /' "$workdir/ag_out"
      msg -i 2 -c 1 "Test failed. ($disp: $status)"
    fi
    ((total += pts))
    ((score += tscore))
    pscore


    function packtest() {
      cd "$inputdir"
      msg -i 2 "Creating test setup"
      tput setaf 58; tree -F . | sed 's/^/    | /'; tput sgr0
      cmd=("$archive" * "out.arch")
      msg -i 2 -c 3 "${cmd[@]}"
      ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
      read disp status <"$workdir/ag_log"
      ccrash
      cp "out.arch" "$outputdir/out.arch"
      cd "$outputdir"
      timeout 5 "$sample" "out.arch" &>/dev/null

      if [[ "$disp" == "Exited" && "$status" == "0" ]]
      then
        if diff -qr "$outputdir" "$inputdir" &>"$workdir/diff"
        then
          msg -i 2 -c 2 "Test passed! ($disp: $status)"
          ((tscore+=pts))
        else
          sed 's/^/  |/' "$workdir/diff"
          msg -i 2 -c 1 "Test failed. Archive file is incorrect."
        fi
      else
        sed 's/^/  | /' "$workdir/ag_out"
        msg -i 2 -c 1 "Test failed. ($disp: $status)"
      fi
      ((total += pts))
      ((score += tscore))
      pscore
    }
      

    # ARCHIVES EMPTY FILE
    rm -rf "$outputdir/"* "$inputdir/"*
    touch "$inputdir/empty"
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Archives empty file ($pts points)"
    packtest

    # ARCHIVES RANDOM FILE
    rm -rf "$outputdir/"* "$inputdir/"*
    head -c4096 /dev/random | base64 >"$inputdir/random"
    echo
    pts=10
    tscore=0
    msg "TEST $((++tn)): Archives random file ($pts points)"
    packtest

    # ARCHIVES RANDOM FILES
    rm -rf "$outputdir/"* "$inputdir/"*

    for f in random{1..10}
    do
      head -c100 /dev/random | base64 >"$inputdir/$f"
    done
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Archives multiple random files ($pts points)"
    packtest

    # ARCHIVES EMPTY DIRECTORY
    rm -rf "$outputdir/"* "$inputdir/"*
    mkdir "$inputdir/emptydir"
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Archives empty directory ($pts points)"
    packtest
    

    # ARCHIVES DIRECTORY WITH FILES
    rm -rf "$outputdir/"* "$inputdir/"*
    mkdir "$inputdir/dir"
    for f in random{1..10}
    do
      head -c100 /dev/random | base64 >"$inputdir/dir/$f"
    done

    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Archives directory containing files ($pts points)"
    packtest
    

    # ARCHIVES MULTIPLE DIRECTORIES WITH FILES
    rm -rf "$outputdir/"* "$inputdir/"*
    for d in dir{1..3}
    do
      mkdir "$inputdir/$d"
      for f in random{1..5}
      do
        head -c100 /dev/random | base64 >"$inputdir/$d/$f"
      done
    done

    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Archives multiple directories containing files ($pts points)"
    packtest

    # ARCHIVES NESTED DIRECTORIES WITH FILES
    rm -rf "$outputdir/"* "$inputdir/"*
    for d in dir{1..4}
    do
      for sd in subdir{1..3}
      do
        mkdir -p "$inputdir/$d/$sd"
        for f in random{1..5}
        do
          head -c100 /dev/random | base64 >"$inputdir/$d/$sd/$f"
        done
      done
    done

    echo
    pts=15
    tscore=0
    msg "TEST $((++tn)): Archives multiple nested directories containing files ($pts points)"
    packtest

    # IGNORES NON-FILES
    rm -rf "$outputdir/"* "$inputdir/"*
    
    mkfifo "$inputdir/fifo"
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Ignores files that are not directories or regular files ($pts points)"
    cd "$inputdir"
    msg -i 2 "Creating test setup"
    tput setaf 58; tree -F . | sed 's/^/    | /'; tput sgr0
    cmd=("$archive" * "out.arch")
    msg -i 2 -c 3 "${cmd[@]}"
    ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
    read disp status <"$workdir/ag_log"
    ccrash

    if [[ "$disp" == "Exited" && "$status" == "0" ]]
    then
      if [ ! -s out.arch ]
      then
        msg -i 2 -c 2 "Test passed! ($disp: $status)"
        ((tscore+=pts))
      else
        msg -i 2 -c 1 "Test failed. Archive file should be empty (size: $(wc -c <out.arch) bytes)."
      fi
    else
      sed 's/^/  | /' "$workdir/ag_out"
      msg -i 2 -c 1 "Test failed. ($disp: $status)"
    fi
    ((total += pts))
    ((score += tscore))
    pscore
    

    function unpacktest() {
      cd "$outputdir"
      msg -i 2 "Creating test setup"
      tput setaf 58; tree -F . | sed 's/^/    | /'; tput sgr0
      "$sample" * in.arch &>/dev/null
      
      cp in.arch "$inputdir"
      cd "$inputdir"

      cmd=("$archive" "in.arch")
      msg -i 2 -c 3 "${cmd[@]}"
      ag "$workdir/ag_log" "${cmd[@]}" &>"$workdir/ag_out"
      read disp status <"$workdir/ag_log"
      ccrash

      if [[ "$disp" == "Exited" && "$status" == "0" ]]
      then
        if diff -qr "$outputdir" "$inputdir" &>"$workdir/diff"
        then
          msg -i 2 -c 2 "Test passed! ($disp: $status)"
          ((tscore+=pts))
        else
          sed 's/^/  |/' "$workdir/diff"
          msg -i 2 -c 1 "Test failed. Unpacked file/structure does not match."
        fi
      else
        sed 's/^/  | /' "$workdir/ag_out"
        msg -i 2 -c 1 "Test failed. ($disp: $status)"
      fi
      ((total += pts))
      ((score += tscore))
      pscore
    }
    

    # UNPACKS EMPTY FILE
    rm -rf "$outputdir/"* "$inputdir/"*
    touch "$outputdir/empty"
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Unpacks empty file ($pts points)"
    unpacktest
      
    # UNPACKS RANDOM FILE
    rm -rf "$outputdir/"* "$inputdir/"*
    head -c4096 /dev/random | base64 >"$outputdir/random"
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Unpacks random file ($pts points)"
    unpacktest

    # UNPACKS EMPTY DIRECTORY
    rm -rf "$outputdir/"* "$inputdir/"*
    mkdir -p "$outputdir/empty"
    echo
    pts=5
    tscore=0
    msg "TEST $((++tn)): Unpacks empty directory ($pts points)"
    unpacktest
    
    # UNPACKS DIRECTORY WITH FILES
    rm -rf "$outputdir/"* "$inputdir/"*
    mkdir "$outputdir/dir"
    for f in random{1..5}
    do
      head -c1000 /dev/random | base64 >"$outputdir/dir/$f"
    done
    echo
    pts=10
    tscore=0
    msg "TEST $((++tn)): Unpacks directory with files ($pts points)"
    unpacktest
    
    # UNPACKS FULLY NESTED TREE
    rm -rf "$outputdir/"* "$inputdir/"*
    for d in dir{1..4}
    do
      for sd in subdir{1..3}
      do
        mkdir -p "$outputdir/$d/$sd"
        for f in random{1..5}
        do
          head -c100 /dev/random | base64 >"$outputdir/$d/$sd/$f"
        done
      done
    done
    echo
    pts=15
    tscore=0
    msg "TEST $((++tn)): Unpacks directory with files ($pts points)"
    unpacktest

    echo
    pts=15
    if [[ crashed -eq 0 ]]
    then
      msg "Never crashed! (+15)"
      tscore=15
    else
      msg -c 1 "A crash was detected :("
      tscore=0
    fi
    ((score+=tscore))
    ((total+=pts))
    msg "Final score: $score/$total ($tscore/$pts)"
  )
  rm -rf "$archive" "$outputdir" "$inputdir" "$workdir"
