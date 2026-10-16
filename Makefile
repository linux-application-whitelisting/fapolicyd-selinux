# Copyright (C) 2018 Thomas Mueller
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

TARGETS?=fapolicyd
MODULES?=${TARGETS:=.pp.bz2}
SHAREDIR?=/usr/share
DIST_VERSION?=$(shell cat VERSION)
DIST_NAME?=fapolicyd-selinux-$(DIST_VERSION)

all: ${TARGETS:=.pp.bz2}

%.pp.bz2: %.pp
	@echo Compressing $^ -\> $@
	bzip2 -9 $^

%.pp: %.te
	make -f ${SHAREDIR}/selinux/devel/Makefile $@

clean:
	rm -f *~  *.tc *.pp *.pp.bz2
	rm -rf tmp *.tar.gz

dist:
	@echo Creating $(DIST_NAME).tar.gz
	git archive --format=tar.gz --prefix=$(DIST_NAME)/ -o $(DIST_NAME).tar.gz HEAD

man: install-policy
	sepolicy manpage --path . --domain ${TARGETS}_t

install-policy: all
	semodule -i ${TARGETS}.pp.bz2
	semodule -i fapolicyd-hardening.cil

install: man
	install -D -m 644 ${TARGETS}.pp.bz2 ${DESTDIR}${SHAREDIR}/selinux/packages/${TARGETS}.pp.bz2
	install -D -m 644 ${TARGETS}-hardening.cil ${DESTDIR}${SHAREDIR}/selinux/packages/${TARGETS}-hardening.cil
	install -D -m 644 ${TARGETS}.if ${DESTDIR}${SHAREDIR}/selinux/devel/include/distributed/${TARGETS}.if
	install -D -m 644 ${TARGETS}_selinux.8 ${DESTDIR}${SHAREDIR}/man/man8/

