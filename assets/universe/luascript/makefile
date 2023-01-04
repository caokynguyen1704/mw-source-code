READTIME = 1
check:
	@echo "****************代码检测*******************"
	@rm -rf ./a.txt
	@find . -name "*.lua" -exec lua {} \;>>a.txt
	@cat ./a.txt
	@rm -rf ./a.txt
	@echo "*******************************************"
svr:
	cd /home/Administrator/work/container/lua/services && make && cd -
dbg:
	cp -f *.lua ../../dbg/luascript/
md5:
	#git pull
	find . -name "*.lua" -exec luajit {} \;
	cp -f ./accountcs.lua ../services/accountcs.lua
	cp -rf ./errorcode.lua ../errorcode.lua
	/bin/sh ./ziplist.sh
	cd /usr/local/mmog/cluster/cfg && tar zcvf /tmp/update.tgz account_def.lua account_def.data online_def.lua online_def.data md5list.lua update/ && cd - && cp /tmp/update.tgz .
	#cd /usr/local/mmog/cluster/cfg && ./restartconn.sh && cd -
	#git ci -a -m'ben'
	git add /usr/local/mmog/cluster/container/lua/client
	git commit -m "client md5"
	git push
	@echo "****************代码检测*******************"
	@rm -rf ./a.txt
	@find . -name "*.lua" -exec lua {} \;>>a.txt
	@cat ./a.txt
	@rm -rf ./a.txt
	@echo "*******************************************"
update:
	cd /usr/local/mmog/cluster/container/shell;./os;cd -
	cd /usr/local/mmog/cluster/cfg && tar zxvf ../container/lua/client/update.tgz && cd -
	cd /usr/local/mmog/cluster/container/lua/client/; ./cdn.sh; cd -
	cd /usr/local/mmog/cluster/cfg ; git add . ; git ci -m" update at `date +%F` "

trans: 
	cd /usr/local/mmog/tools/transtable && ./trans && cd -


test:
	git pull
	find . -name "*.lua" -exec luajit {} \;
	cp -f ./accountcs.lua ../services/accountcs.lua
	cp -rf ./errorcode.lua ../errorcode.lua
	/bin/sh ./ziplist.sh
	cd /usr/local/mmog/cluster/cfg && ./restart.sh && cd -
