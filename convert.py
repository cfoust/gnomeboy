import os
import math

roms = open("roms.lua", 'wb')

roms.write("GB_ROMS = {\n")

for filename in os.listdir("roms/"):
	if filename[-3:] == ".gb":
		roms.write("{\n");
		romfile = open("roms/" + filename, 'rb')
		bytes = ""
		for b in romfile.read():
			bytes = bytes + "%02X" % ord(b)
		roms.write("\t[\"name\"] = \"" + filename + "\",\n");

		numChunks = math.ceil(len(bytes)/128)
		for i in range(int(numChunks)):
			sub = bytes[i*128:(i+1)*128];
			roms.write("\t\"" + sub + "\",\n" );

		roms.write("},\n");

roms.write("\n}")