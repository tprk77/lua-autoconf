#!/bin/bash

function enter_dir {
	echo "now testing in: $1"
	cd $1

	if [ ! -d m4 ]; then mkdir m4; fi
	cp ../../ax_lua2.m4 ./m4/ax_lua2.m4
	cp ../ax_compare_version.m4 ./m4/ax_compare_version.m4

	autoreconf -i
}

function leave_dir {
	rm -rf aclocal.m4 autom4te.cache m4
	rm -rf install-sh missing
	rm -rf config.log config.status configure
	rm -rf Makefile Makefile.in
	cd ..
}

function conf_test {
	# tests that should pass
	for conf_args in "$@"; do
		echo "now testing: ./configure $conf_args"
		./configure $conf_args
		if [ "x$?" != 'x0' ]; then
			echo "[TEST FAILED]" 1>&2
		else
			echo "[TEST PASSED]"
		fi
	done
}

function neg_conf_test {
	# tests that should fail
	for conf_args in "$@"; do
		echo "now testing: ./configure $conf_args"
		./configure $conf_args
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

