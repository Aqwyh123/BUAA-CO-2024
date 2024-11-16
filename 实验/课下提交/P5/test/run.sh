# Mars_CO_v0.5.0.jar
# Author: Toby-Shi-cloud
# Address: https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension

src="../src"
sim_time="1us"
debug=true # 作者测试使用，不要修改为true

if [ -d "./build" ]; then
    rm -r ./build
fi
mkdir ./build
if [ -d "./out" ]; then
    rm -r ./out
fi
mkdir ./out
if [ -d "./analysis/work" ]; then
    rm -r ./analysis/work
fi
mkdir ./analysis/work
if [ -d "./analysis/result" ]; then
    rm -r ./analysis/result
fi
mkdir ./analysis/result

cp code.asm ./out

java -jar Mars_CO_v0.5.0.jar ./out/code.asm db nc mc CompactDataAtZero a dump .text HexText ./out/code.txt
java -jar Mars_CO_v0.5.0.jar ./out/code.asm db nc ig mc CompactDataAtZero coL1 > ./out/stdout.txt

cd ./analysis
java -jar ./Hazard-Calculator.jar --hz ../out/code.txt > ../out/pipeline_cycle.txt
cd ..
mv ./analysis/hazard.json ./out/hazard_info.json

cd ./out
zip P5_TestCase0.zip code.txt > /dev/null
cd ..
mv ./out/P5_TestCase0.zip ./analysis/work
cd ./analysis/work
zip P5.zip P5_TestCase0.zip > /dev/null
cd ../..
rm ./analysis/work/P5_TestCase0.zip
cd ./analysis
yes "Y" | python3 ./analyzer.py > /dev/null
cd ..
mv ./analysis/result/*.json ./out/hazard_coverage.json

cp $src/*.v ./build
if [ $debug = true ]; then
    rm ./build/macros.v
    cp *.v ./build
fi

mkdir ./build/sim
cp ./out/code.txt ./build/sim
cd ./build
vcs -full64 *.v -o sim/simv -fsdb -kdb -q
cd sim
./simv +vcs+finish+$sim_time +fsdbfile+wave.fsdb -q | grep @ > output_with_time.txt
mv ./output_with_time.txt ../../out/output_with_time.txt
mv ./wave.fsdb ../../out/wave.fsdb
cd ../..

python3 tools.py
diff -B ./out/stdout.txt ./out/output.txt > ./out/diff.txt
rm -r ./build
