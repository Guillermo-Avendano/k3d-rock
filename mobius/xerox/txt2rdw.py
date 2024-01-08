import sys

def convert1(input_file_path, output_file_path):
	# Chunk size for reading the input file
	chunk_size = 32760  # Adjust this size based on your needs

	# Open input and output files
	with open(input_file_path, 'r', encoding='ANSI') as fi, open(output_file_path, 'wb') as fo:
		while True:
			chunk = fi.read(chunk_size)
			if not chunk:
				break

			# Process each chunk
			for line in chunk.splitlines():
				res = line.rstrip()
				ll = len(res) + 4
				res_ebc = res.encode('cp500')
				if res == '\x1a':
					res_ebc = b'\x1c'
				rdw = ll.to_bytes(2, byteorder='big') + b'\x00\x00'

				# Write RDW followed by the record to the output file
				fo.write(rdw + res_ebc)

	print("Conversion completed.")

def convert_chema(fin, fout):
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
fout="C:/Rocket.Git/k3d-rock/mobius/xerox/MCOPT105.RDW"

convert1 (fin, fout)