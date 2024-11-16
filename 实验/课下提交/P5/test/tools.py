with open("./out/output.txt", "w") as fo:
    lines = []
    with open("./out/output_with_time.txt", "r") as fi:
        lines = fi.readlines()
    for line in lines:
        if(line.startswith(" ")):
            line = line[line.find("@"):]
            fo.write(line)