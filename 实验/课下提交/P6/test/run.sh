#!/bin/bash

src="../src"
sim_time="20us"

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
    # empty_dir "./analysis/work"
    # empty_dir "./analysis/result"
}

function make_data(){
    mkdir "./out/$1"
    java -jar dataMaker6.jar > "./out/$1/code.asm"
    java -jar Mars*.jar "./out/$1/code.asm" db nc mc CompactLargeText a dump .text HexText "./out/$1/code.txt"
    java -jar Mars*.jar "./out/$1/code.asm" db nc ig mc CompactLargeText coL1 > "./out/$1/stdout.txt"
}

function analyze(){
    # cd ./analysis || exit
    # java -jar ./Hazard-Calculator.jar --hz ../out/code.txt > ../out/pipeline_cycle.txt
    # cd ..
    # mv ./analysis/hazard.json ./out/hazard_info.json
    # cd ./out || exit
    # zip P6_TestCase0.zip code.txt > /dev/null
    # cd ..
    # mv ./out/P6_TestCase0.zip ./analysis/work
    # cd ./analysis/work || exit
    # zip P6.zip P6_TestCase0.zip > /dev/null
    # cd ../..
    # rm ./analysis/work/P6_TestCase0.zip
    # cd ./analysis || exit
    # echo "Y" | python3 ./analyzer.py > /dev/null
    # cd ..
    # mv ./analysis/result/*.json ./out/hazard_coverage.json
    if [ -s "./out/$1/diff.txt" ]; then
        echo "Test case $1 failed"
    else
        echo "Test case $1 passed"
    fi
}

function compile {
    cp $src/*.v ./build
    cd ./build || exit
    mkdir ./sim
    vcs -full64 ./*.v -o sim/simv -fsdb -kdb -q
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
    echo "$1" | python3 tools.py
    diff -B "./out/$1/stdout.txt" "./out/$1/output.txt" > "./out/$1/diff.txt"
}

function end_test {
    rm -r ./build
    # rm -r ./analysis/work/*
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
        make_data "$i"
        simulate "$i"
        process "$i"
        analyze "$i"
    done
    end_test
}

main "$@"
