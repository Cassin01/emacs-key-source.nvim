all: lua/emacs-key-source/kmp.lua lua/ lua/emacs-key-source/init.lua

lua/%.lua: fnl/%.fnl
	fennel --compile $< > $@
