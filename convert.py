import os
 
filename = raw_input("Drag and drop the file you want to convert")

filename = os.path.normpath(filename.strip().strip('\'\"'))
 
infile  = open(filename, 'rb')
outfile = open(filename + "_hex" + ".lua", 'wb')
outfile.write("MegaRom = \"")
for b in infile.read():
        outfile.write("%02X" % ord(b))

outfile.write("\"")
infile.close()
outfile.close()
 
print("Done!")
raw_input("Press enter to close.")