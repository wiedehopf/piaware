PREFIX=/usr
LIB=$(PREFIX)/lib/piaware_packages
TCLSH=$(shell which tclsh || which tclsh8.6 || which tclsh8.5)

FILES=fa_piaware_config.tcl fa_adept_client.tcl fa_sudo.tcl fa_services.tcl fa_sysinfo.tcl fa_gps.tcl piaware.tcl tryfinallyshim.tcl egm96.tcl egm96geoid.tcl

all:
	@echo '"make install" to install'

pkgIndex.tcl: $(FILES)
	echo 'pkg_mkIndex .' | $(TCLSH)

install: pkgIndex.tcl
	install -d $(DESTDIR)$(LIB) $(DESTDIR)$(LIB)/ca
	install $(FILES) pkgIndex.tcl $(DESTDIR)$(LIB)
	install ca/*.pem $(DESTDIR)$(LIB)/ca
	c_rehash $(DESTDIR)$(LIB)/ca
	$(MAKE) -C helpers install
	$(MAKE) -C fa_adept_codec install

clean:
	$(MAKE) -C helpers clean
