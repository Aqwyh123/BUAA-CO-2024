import sys

with open(sys.argv[2], "w") as fo:
    lines = []
    with open(sys.argv[1], "r") as fi:
        lines = fi.readlines()
    for line in lines:
        if(line.startswith(" ")):
            line = line[line.find("@"):]
            fo.write(line)