#!/bin/bash

src="../src" # 源文件目录
sim_time="20us" # 仿真时间
# 下方一般无须修改
data_maker="./dataMaker7.jar"
# nop_filler="./nop_filler.cpp"
# handler="./handler.asm"
mars="./Mars/Mars_COKiller.jar"
make_timeout="10s"

function empty_dir(){
    if [ -d "$1" ]; then
        rm -r "${1:?}"/* > /dev/null
    else
        mkdir "$1"
    fi
}

function start_test {
    empty_dir "./build"
    empty_dir "./out"
    # g++ $nop_filler -o ./build/nop_filler
    # java -jar $mars $handler db nc mc a LargeText dump .text HexText "./out/handler.txt"
}

function make_data(){
    mkdir "./out/$1"
    java -jar $data_maker > "./out/$1/code.asm"
    # ./build/nop_filler "./out/$1/code.asm" $handler "./out/$1/code.asm"
    java -jar $mars "./out/$1/code.asm" db nc a mc LargeText dump .text HexText "./out/$1/code.txt"
    if ! timeout $make_timeout java -jar $mars "./out/$1/code.asm" db nc ex lg mc LargeText > "./out/$1/stdout.txt" ; then
        echo "Test case $1 invalid"
        rm -r "./out/$1"
        return 1
    fi
    python3 code_filler.py "./out/$1/code.txt"
}

function analyze(){
    if [ -s "./out/$1/diff.txt" ]; then
        echo "Test case $1 failed"
    else
        echo "Test case $1 passed"
        rm -r "./out/$1"
    fi
}

function compile {
    cp $src/*.v ./build
    cd ./build || exit
    mkdir ./sim
    vcs -full64 ./*.v -o sim/simv -q
    cd ..
}

function simulate(){
    cp "./out/$1/code.txt" ./build/sim
    cd ./build/sim || exit
    ./simv +vcs+finish+$sim_time -q | grep @ > output_with_time.txt
    mv ./output_with_time.txt "../../out/$1/output_with_time.txt"
    cd ../..
}

function process(){
    python3 time_remover.py "./out/$1/output_with_time.txt" "./out/$1/output.txt"
    diff -B "./out/$1/stdout.txt" "./out/$1/output.txt" > "./out/$1/diff.txt"
}

function end_test {
    rm -r ./build
}

function main {
    if [ $# -eq 1 ]; then
        test_round=$1
    else
        test_round=10
    fi
    start_test
    compile
    for i in $(seq 1 "$test_round"); do
        if ! make_data "$i"; then
            continue
        fi
        simulate "$i"
        process "$i"
        analyze "$i"
    done
    end_test
}

main "$@"
