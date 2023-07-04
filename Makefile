
install:
	mkdir -p "${DESTDIR}"/usr/bin/
	cd bin && for e in *.sh ; do \
		x=$${e/.sh}; \
		install $$e "${DESTDIR}"/usr/bin/$$x ; \
	done

test:
	for f in t/*.sh ; do bash -x $$f && continue; echo FAIL: $$f; break; done

test_leap:
	for f in t/*.sh; do echo starting $$f; ENVIRON_TEST_IMAGE=registry.opensuse.org/opensuse/leap $$f && continue; echo FAIL $$f; break; done

test_tw:
	for f in t/*.sh; do echo starting $$f; ENVIRON_TEST_IMAGE=registry.opensuse.org/opensuse/tumbleweed $$f && continue; echo FAIL $$f; break; done
