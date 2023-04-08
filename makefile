all:
	@make release
	@make debug

debug:
	swift build -c debug

release:
	swift build -c release

install:
	cp -f .build/release/termcalc /usr/local/bin/termcalc
