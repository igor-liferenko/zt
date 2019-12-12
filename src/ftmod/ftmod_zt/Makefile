scp:
	scp ~/zt/src/ftmod/ftmod_zt/ftmod_zt.w l:zt/src/ftmod/ftmod_zt/

tex:
	scp ~/zt/src/ftmod/ftmod_zt/ftmod_zt.w l:zt/src/ftmod/ftmod_zt/
	ssh l 'cd zt/src/ftmod/ftmod_zt/ && cweave ftmod_zt'
	scp l:zt/src/ftmod/ftmod_zt/ftmod_zt.\{tex,scn,idx\} .
	tex ftmod_zt
