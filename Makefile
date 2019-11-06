DESTDIR =

prefix = /usr/local
sysconfdir = $(prefix)/etc
localstatedir = $(prefix)/var


files_static = \
	default/grub \
	ld.so.conf \
	crypttab

files_build =

links =

dirs = \
	default


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
	mkdir -p $(DESTDIR)/boot/grub
	chroot $(DESTDIR)/ grub-mkconfig -o /boot/grub/grub.cfg
	chroot $(DESTDIR)/ ldconfig

install-files: install-etc

install-etc: $(files_static) $(files_build)
	mkdir -p $(DESTDIR)$(sysconfdir)
	cd $(DESTDIR)$(sysconfdir) && mkdir -p $(dirs)
	cp -f default/grub $(DESTDIR)$(sysconfdir)/default
	cp -f ld.so.conf $(DESTDIR)$(sysconfdir)
	cp -f crypttab $(DESTDIR)$(sysconfdir)
	chmod go= $(DESTDIR)$(sysconfdir)/crypttab

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
