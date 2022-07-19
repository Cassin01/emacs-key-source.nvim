all: lua/emacs-key-source/kmp.lua lua/ lua/emacs-key-source/source.lua

lua/%.lua: fnl/%.fnl
	fennel --compile $< > $@
