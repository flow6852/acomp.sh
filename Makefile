TARGET=acomp.sh
INSDIR=$(HOME)/.local/bin


install:
	mkdir -p $(HOME)/.config/acomp
	cp src/$(TARGET) $(INSDIR)/$(TARGET)
	cp confs/* $(HOME)/.config/acomp
	echo "...installed"

uninstall:
	rm $(INSDIR)/$(TARGET)
	rm -rf $(HOME)/.config/acomp
	echo "...uninstalled"
