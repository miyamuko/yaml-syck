SYCK_ARC = syck-0.61+svn231+patches.tar.gz
SYCK_DIR = syck-0.61+svn231+patches
SYCK_URL = http://pyyaml.org/download/pysyck/syck-0.61+svn231+patches.tar.gz

DEF      = syck.def
TARGET   = syck.dll

all: syck.dll xyck.dll

prep: get extract configure

get:
	wget $(SYCK_URL)

extract:
	tar zxvf $(SYCK_ARC)

configure:
	cd $(SYCK_DIR);      \
	./configure


$(SYCK_DIR)/Makefile: configure

$(SYCK_DIR)/libsyck.a: $(SYCK_DIR)/Makefile
	cd $(SYCK_DIR);      \
	make

syck.dll: $(SYCK_DIR)/libsyck.a
	cd $(SYCK_DIR)/lib;  \
	dllwrap -k -def ../../$(DEF) --driver-name gcc -o ../../$(TARGET) *.o

xyck.dll: $(SYCK_DIR) $(DEF)
	make -f Makefile.xyck

dist:
	cp $(TARGET) ../ffi

clean:
	make -f Makefile.xyck clean
	rm -f $(TARGET)
	cd $(SYCK_DIR)       \
	make clean

distclean:
	rm -rf $(SYCK_DIR)
	rm -f $(SYCK_ARC)
