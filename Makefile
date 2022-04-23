DESTDIR =
FSTAB = uefi
HOSTNAME = localhost
USER_NAME = user
USER_UID = 1000
USER_GID = $(USER_UID)
USER_SHELL = /bin/sh
ARCH = x86_64

prefix = /usr/local
sysconfdir = $(prefix)/etc
localstatedir = $(prefix)/var

pacman_cachedir = $(localstatedir)/cache/pacman
pacman_repodir = $(localstatedir)/lib/pacman/repo


files_static = \
	default/grub \
	ld.so.conf \
	crypttab \
	securetty issue motd shells \
	profile \
	pacman.conf pacman.d/nop.conf \
	sudoers

files_build = \
	fstab \
	hostname \
	passwd shadow group gshadow

links = \
	systemd/network/99-default.link

dirs = \
	default \
	pacman.d \
	systemd/network


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
	chroot $(DESTDIR)/ systemd-sysusers

install-files: install-etc
	mkdir -p $(DESTDIR)/home/$(USER_NAME)
	chmod 750 $(DESTDIR)/home/$(USER_NAME)
	chown $(USER_UID):$(USER_GID) $(DESTDIR)/home/$(USER_NAME)
	mkdir -p $(DESTDIR)$(pacman_repodir)/custom/$(ARCH)
	touch -a $(DESTDIR)$(pacman_repodir)/custom/$(ARCH)/custom.db \
	         $(DESTDIR)$(pacman_repodir)/custom/$(ARCH)/custom.files
	mkdir -p $(DESTDIR)$(pacman_repodir)/aur/$(ARCH)
	touch -a $(DESTDIR)$(pacman_repodir)/aur/$(ARCH)/aur.db \
	         $(DESTDIR)$(pacman_repodir)/aur/$(ARCH)/aur.files
	mkdir -p $(DESTDIR)$(pacman_cachedir)
	test -d $(DESTDIR)$(pacman_cachedir)/custom || \
	ln -sf $(pacman_repodir)/custom/$(ARCH) \
	       $(DESTDIR)$(pacman_cachedir)/custom
	test -d $(DESTDIR)$(pacman_cachedir)/aur || \
	ln -sf $(pacman_repodir)/aur/$(ARCH) \
	       $(DESTDIR)$(pacman_cachedir)/aur

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
	cp -f pacman.conf $(DESTDIR)$(sysconfdir)
	cp -f pacman.d/nop.conf $(DESTDIR)$(sysconfdir)/pacman.d
	cp -f sudoers $(DESTDIR)$(sysconfdir)
	chmod 400 $(DESTDIR)$(sysconfdir)/sudoers
	ln -sf /dev/null $(DESTDIR)$(sysconfdir)/systemd/network/99-default.link

uninstall: uninstall-files

uninstall-files: uninstall-etc
	rm -f $(DESTDIR)$(pacman_cachedir)/aur \
	      $(DESTDIR)$(pacman_cachedir)/custom
	-rmdir $(DESTDIR)$(pacman_cachedir)
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
