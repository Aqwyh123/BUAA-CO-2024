# Mars_CO_v0.5.0.jar
# Author: Toby-Shi-cloud
# Address: https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension

mode1="cpp"
mode2="py"
XILINX="/opt/Xilinx/14.7/ISE_DS/ISE/"
TestBench="../../MIPS_Single_Cycle/MIPS_Single_Cycle_TB.v"

mkdir .build
cd .build

read -p "Please input the mode (cpp/py): " mode

if [ $mode = $mode1 ];
then
    g++ ../generate.cpp -o generate
    ./generate > std.asm
elif [ $mode = $mode2 ];
then
    yes "all" | python ../generate.py 
else
    echo "Error: Invalid mode"
    rm -r ../.build
    exit 1
fi

java -jar ../Mars_CO_v0.5.0.jar a mc CompactDataAtZero dump .text HexText code.txt std.asm

gcc ../mips.c -o mips
./mips < code.txt > stdout.txt

cp code.txt ../code.txt
cp stdout.txt ../stdout.txt

cp ../../*.v ./
cp $TestBench ./

array=(`ls *.v`)
for var in ${array[@]}
do
    echo "Verilog work \"$var\"" >> mips.prj
done
echo "run 1000us;" >> mips.tcl
echo "exit" >> mips.tcl

$XILINX/bin/lin64/fuse -nodebug -prj mips.prj -o my_mips.exe MIPS_Single_Cycle_TB
./my_mips.exe -intstyle ise -tclbatch mips.tcl > output.txt

cp output.txt ../output.txt
rm -r ../.build
