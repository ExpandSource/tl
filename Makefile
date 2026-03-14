CC      = gcc
CFLAGS  = -Wall -Wextra -O2
TARGET  = tl
SRC     = src/tl.c
VERSION = 0.0.1

PREFIX    = /usr/local
SHARE_DIR = /usr/share/tl/modules

.PHONY: all clean install uninstall dist deb

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $<

install: $(TARGET)
	install -Dm755 $(TARGET) $(PREFIX)/bin/$(TARGET)
	find modules -type d | while read d; do \
		dest=$(SHARE_DIR)/$${d#modules/}; \
		install -dm755 "$$dest"; \
	done
	find modules -name "*.txt" -o -name "*.conf" | while read f; do \
		dest=$(SHARE_DIR)/$${f#modules/}; \
		install -m644 "$$f" "$$dest"; \
	done

uninstall:
	rm -f $(PREFIX)/bin/$(TARGET)
	rm -rf /usr/share/tl

# tarball 패키지
dist: $(TARGET)
	mkdir -p dist/tl-$(VERSION)/{bin,modules}
	cp $(TARGET)             dist/tl-$(VERSION)/bin/
	cp -r modules/.          dist/tl-$(VERSION)/modules/
	cp install.sh            dist/tl-$(VERSION)/
	cp README.md             dist/tl-$(VERSION)/
	tar -czf dist/tl-$(VERSION).tar.gz -C dist tl-$(VERSION)
	rm -rf dist/tl-$(VERSION)
	@echo "생성됨: dist/tl-$(VERSION).tar.gz"

# .deb 패키지
deb: $(TARGET)
	mkdir -p dist/deb/tl_$(VERSION)/DEBIAN
	mkdir -p dist/deb/tl_$(VERSION)/usr/local/bin
	mkdir -p dist/deb/tl_$(VERSION)/usr/share/tl/modules
	cp $(TARGET) dist/deb/tl_$(VERSION)/usr/local/bin/
	cp -r modules/. dist/deb/tl_$(VERSION)/usr/share/tl/modules/
	sed "s/VERSION/$(VERSION)/" pkg/control.tmpl > dist/deb/tl_$(VERSION)/DEBIAN/control
	dpkg-deb --build dist/deb/tl_$(VERSION) dist/tl_$(VERSION).deb
	rm -rf dist/deb
	@echo "생성됨: dist/tl_$(VERSION).deb"

clean:
	rm -f $(TARGET)
	rm -rf dist
