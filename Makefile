DESTDIR =
FSTAB = uefi
HOSTNAME = localhost
USER_NAME = user
USER_UID = 1000
USER_GID = $(USER_UID)
USER_SHELL = /bin/sh

prefix = /usr/local
sysconfdir = $(prefix)/etc
localstatedir = $(prefix)/var


files_static = \
	default/grub \
	ld.so.conf \
	crypttab \
	securetty issue motd shells \
	profile

files_build = \
	fstab \
	hostname \
	passwd shadow group gshadow

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
	mkdir -p $(DESTDIR)/home/$(USER_NAME)
	chmod 750 $(DESTDIR)/home/$(USER_NAME)
	chown $(USER_UID):$(USER_GID) $(DESTDIR)/home/$(USER_NAME)

install-etc: $(files_static) $(files_build)
	mkdir -p $(DESTDIR)$(sysconfdir)
	cd $(DESTDIR)$(sysconfdir) && mkdir -p $(dirs)
	cp -f default/grub $(DESTDIR)$(sysconfdir)/default
	cp -f ld.so.conf $(DESTDIR)$(sysconfdir)
	cp -f crypttab fstab $(DESTDIR)$(sysconfdir)
	chmod go= $(DESTDIR)$(sysconfdir)/crypttab
	cp -f hostname $(DESTDIR)$(sysconfdir)
	cp -f securetty issue motd shells $(DESTDIR)$(sysconfdir)
	cp -f passwd shadow group gshadow $(DESTDIR)$(sysconfdir)
	chmod go= $(DESTDIR)$(sysconfdir)/shadow \
	          $(DESTDIR)$(sysconfdir)/gshadow
	cp -f profile $(DESTDIR)$(sysconfdir)

uninstall: uninstall-files

uninstall-files: uninstall-etc
	-rmdir $(DESTDIR)/home/$(USER_NAME)

uninstall-etc:
	cd $(DESTDIR)$(sysconfdir) && \
	rm -f $(files_static) $(files_build) $(links)
	-cd $(DESTDIR)$(sysconfdir) && rmdir -p $(dirs)


.SUFFIXES:
.SUFFIXES: .in

.in:
	sed -e 's/@HOSTNAME@/$(HOSTNAME)/g' \
	    -e 's/@USER_NAME@/$(USER_NAME)/g' \
	    -e 's/@USER_UID@/$(USER_UID)/g' \
	    -e 's/@USER_GID@/$(USER_GID)/g' \
	    -e 's|@USER_SHELL@|$(USER_SHELL)|g' \
	    $< > $@


fstab:
	cp -f fstab.in/$(FSTAB) $@
