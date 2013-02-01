#!/bin/bash

function enter_dir {
	echo "[ENTERING $1]"
	cd $1
	if [ ! -d m4 ]; then mkdir m4; fi
	cp ../../ax_lua.m4 ./m4/ax_lua.m4
	cp ../ax_compare_version.m4 ./m4/ax_compare_version.m4
	autoreconf -i
}

function leave_dir {
	echo "[LEAVING $(basename $(pwd))]"
	rm -rf .deps .libs
	rm -rf aclocal.m4 autom4te.cache m4
	rm -rf install-sh missing libtool ltmain.sh depcomp
	rm -rf config.log config.status config.guess config.sub configure
	rm -rf Makefile Makefile.in
	rm -rf local_install
	rm -rf *.o *.lo *.la
	cd ..
}

function conf_test {
	# tests that should pass
	for conf_args in "$@"; do
		echo "[TESTING \`./configure $conf_args\`]"
		./configure --prefix=$(pwd)/local_install $conf_args
		if [ "x$?" != 'x0' ]; then
			echo "[TEST FAILED]" 1>&2
		else
			echo "[TEST PASSED]"
		fi

		echo "[TESTING \`make\`]"
		make
		if [ "x$?" != 'x0' ]; then
			echo "[TEST FAILED]" 1>&2
		else
			echo "[TEST PASSED]"
		fi

		echo "[TESTING \`make install\`]"
		make install
		if [ "x$?" != 'x0' ]; then
			echo "[TEST FAILED]" 1>&2
		else
			echo "[TEST PASSED]"
		fi

		make clean
		rm -f Makefile
	done
}

function neg_conf_test {
	# tests that should fail
	for conf_args in "$@"; do
		echo "[TESTING \`./configure $conf_args\`]"
		./configure --prefix=$(pwd)/local_install $conf_args
		if [ "x$?" = 'x0' ]; then
			echo "[TEST FAILED]" 1>&2
		else
			echo "[TEST PASSED]"
		fi
	done
}

#############################################################################
# Test version requirements and different interpreters.
#############################################################################

if [ ! -f ax_compare_version.m4 ]; then
	wget "http://git.savannah.gnu.org/gitweb/?p=autoconf-archive.git;a=\
blob_plain;f=m4/ax_compare_version.m4" -O ax_compare_version.m4 &>/dev/null
	if [ ! -f ax_compare_version.m4 ]; then
		echo "[CANNOT DOWNLOAD ax_compare_version.m4]"
		exit 1
	fi
fi

enter_dir 'noreq'
conf_test '' 'LUA=lua50' 'LUA=lua5.1' 'LUA=lua5.2'
neg_conf_test 'LUA=badinterp'
leave_dir

enter_dir 'minreq' # test v >= 5.1
conf_test '' 'LUA=lua5.1' 'LUA=lua5.2'
neg_conf_test 'LUA=lua50' 'LUA=badinterp'
leave_dir

enter_dir 'minmaxreq' # tests v >= 5.1, < 5.2
conf_test '' 'LUA=lua5.1'
neg_conf_test 'LUA=lua50' 'LUA=lua5.2' 'LUA=badinterp'
leave_dir

