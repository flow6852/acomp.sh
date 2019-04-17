TARGET=auto_compiler.sh
INSDIR=$(HOME)/.local/bin


install:
	mkdir -p $(HOME)/.config/auto_compiler
	cp src/$(TARGET) $(INSDIR)/$(TARGET)
	cp confs/* $(HOME)/.config/auto_compiler
	echo "...installed"

uninstall:
	rm $(INSDIR)/$(TARGET)
	rm -rf $(HOME)/.config/auto_compiler
	echo "...uninstalled"
