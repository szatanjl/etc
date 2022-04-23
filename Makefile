DESTDIR =

prefix = /usr/local
sysconfdir = $(prefix)/etc
localstatedir = $(prefix)/var


files_static =

files_build =

links =

dirs =


all: $(files_static) $(files_build)

-include config.mk


.PHONY: all clean distclean
.PHONY: install install-files install-etc
.PHONY: uninstall uninstall-files uninstall-etc

clean:
	rm -f $(files_build)

distclean: clean
	rm -f config.mk

install: install-files

install-files: install-etc

install-etc: $(files_static) $(files_build)
	mkdir -p $(DESTDIR)$(sysconfdir)
	cd $(DESTDIR)$(sysconfdir) && mkdir -p $(dirs)

uninstall: uninstall-files

uninstall-files: uninstall-etc

uninstall-etc:
	cd $(DESTDIR)$(sysconfdir) && \
	rm -f $(files_static) $(files_build) $(links)
	-cd $(DESTDIR)$(sysconfdir) && rmdir -p $(dirs)


.SUFFIXES:
.SUFFIXES: .in

.in:
	cp -f $< $@
