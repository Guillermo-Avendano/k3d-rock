import sys

#fin=sys.argv[1]
#fout=sys.argv[2]

fin="C:/Rocket.Git/k3d-rock/mobius/xerox/vader111.datos.txt"
fout="C:/Rocket.Git/k3d-rock/mobius/xerox/vader111.datos.rdw"

#fin="C:/Rocket.Git/k3d-rock/mobius/xerox/MCOPT105.TXT"
#fout="C:/Rocket.Git/k3d-rock/mobius/xerox/MCOPT105.RDW"

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