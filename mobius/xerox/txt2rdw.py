import shutil

def convert1(input_file_path, output_file_path):
	# Open input and output files
	with open(input_file_path, 'rb') as infile, open(output_file_path, 'wb') as outfile:
		# Read input file in chunks
		chunk_size = 32760  # Adjust this size based on your needs
		while True:
			chunk = infile.read(chunk_size)
			if not chunk:
				break

			# Calculate the Record Descriptor Word (RDW) for each record
			rdw = len(chunk).to_bytes(4, byteorder='big')

			# Write RDW followed by the record to the output file
			outfile.write(rdw + chunk)

	print("Conversion completed.")

def twoebcdic(fin, fout):
	fo=open(fout,'wb')
	with open(fin,'rb') as fi:
		while 1:
			line=fi.readline()
			if not line:break
			res=line.rstrip()
			ll=len(res)+4
			res_ebc=res.decode('ANSI').encode('cp500')
			if res==b'\x1a':
				res_ebc=b'\x1c'
			rdw=bytes(chr(int(ll/256))+chr(ll%256)+'\x00\x00',encoding='ANSI')
			fo.write(rdw+res_ebc)
	fo.close()


fin="C:/Rocket.Git/k3d-rock/mobius/xerox/MCOPT105.TXT"
ftmp="C:/Rocket.Git/k3d-rock/mobius/xerox/MCOPT105.TMP"
fout="C:/Rocket.Git/k3d-rock/mobius/xerox/MCOPT105.RDW"

twoebcdic(fin, fout)
#convert1(ftmp, fout)