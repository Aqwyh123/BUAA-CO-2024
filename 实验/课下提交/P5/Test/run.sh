# Mars_CO_v0.5.0.jar
# Author: Toby-Shi-cloud
# Address: https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension

XILINX="/opt/Xilinx/14.7/ISE_DS/ISE/"

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
cp ./out/code.txt ./build/code.txt

cp ../*.v ./build/
cd ./build
array=(`ls *.v`)
cd ..
for var in ${array[@]}; do
    echo "Verilog work \"$var\"" >> ./build/mips.prj
done
echo "verilog work \"/opt/Xilinx/14.7/ISE_DS/ISE//verilog/src/glbl.v\"" >> ./build/mips.prj

echo "run 1000us;" >> ./build/mips.tcl
echo "exit" >> ./build/mips.tcl

cd ./build
$XILINX/bin/lin64/fuse -nodebug -prj mips.prj -o mips mips_TB > mips.log
./mips -nolog -tclbatch mips.tcl > ../out/output.txt
cd ..

diff ./out/stdout.txt ./out/output.txt > ./out/diff.txt
rm -r ./build
echo "下次运行前请自行保留out文件夹"
