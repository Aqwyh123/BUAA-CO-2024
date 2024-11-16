# Mars_CO_v0.5.0.jar
# Author: Toby-Shi-cloud
# Address: https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension

if [ -d "./build" ]; then
    rm -r ./build
fi
mkdir ./build
if [ -d "./out" ]; then
    rm -r ./out
fi
mkdir ./out

read -p "选择模式(cpp/py): " mode
if [ $mode = "cpp" ]; then
    g++ ./src/generate.cpp -o ./build/generate
    ./build/generate > ./out/code.asm
elif [ $mode = "py" ]; then
    yes "all" | python ./src/generate.py
else
    echo "无效模式"
    rm -r ./build
    rm -r ./out
    exit 1
fi

java -jar ./src/Mars_CO_v0.5.0.jar ./out/code.asm db nc mc CompactDataAtZero a dump .text HexText ./out/code.txt 
java -jar ./src/Mars_CO_v0.5.0.jar ./out/code.asm db nc ig mc CompactDataAtZero coL1 > ./out/stdout.txt

cp ../*.v ./build
rm ./build/macros.v
cp ./src/macros.v ./build
cp ./src/mips_TB.v ./build

mkdir ./build/sim
cp ./out/code.txt ./build/sim/code.txt
cd ./build
vcs -full64 *.v -o sim/simv -fsdb -kdb -q
cd sim
./simv +vcs+finish+1us +fsdbfile+wave.fsdb -q > output_with_time.txt
cp ./output.txt ../../out/output.txt
cp ./output_with_time.txt ../../out/output_with_time.txt
cp ./wave.fsdb ../../out/wave.fsdb
cd ../..

diff ./out/stdout.txt ./out/output.txt > ./out/diff.txt
rm -r ./build
echo "下次运行前请自行保留out文件夹"
