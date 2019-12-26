FT_CFLAGS=-g3 -O2 -fPIC -fstack-protector --param=ssp-buffer-size=4 -DHAVE_ZLIB -ffast-math -Wall -Werror -Wunused-variable -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -O0 -g -ggdb -DPACKAGE_NAME=\"freetdm\" -DPACKAGE_TARNAME=\"freetdm\" -DPACKAGE_VERSION=\"0.1\" -DPACKAGE_STRING=\"freetdm\ 0.1\" -DPACKAGE_BUGREPORT=\"bugs@freeswitch.org\" -DPACKAGE_URL=\"\" -DPACKAGE=\"freetdm\" -DVERSION=\"0.1\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -DDEBUG=/\*\*/ -DHAVE_LIBDL=1 -DHAVE_LIBPTHREAD=1 -DHAVE_LIBM=1 -DHAVE_NETDB_H=1 -DHAVE_SYS_SELECT_H=1 -DHAVE_EXECINFO_H=1 -DHAVE_GETHOSTBYNAME_R=1

BASE=../../..
FT_DIR=..
VERBOSE=1
FTLA=$(FT_DIR)/libfreetdm.la
LOCAL_OBJS=
LOCAL_CFLAGS=-I$(FT_DIR)/src/include -I$(FT_DIR)/src/isdn/include $(FT_CFLAGS)
LOCAL_LDFLAGS=-L$(FT_DIR) -lfreetdm 
include modmake.rules

local_depend: $(FTLA)

$(FTLA): .update
	cd $(FT_DIR) && $(MAKE)

local_install:
	cd $(FT_DIR) && $(MAKE) install
	[ -f $(DESTDIR)/etc/autoload_configs/freetdm.conf.xml ] || cp -f $(FT_DIR)/conf/freetdm.conf.xml  $(DESTDIR)/etc/autoload_configs

local_clean:
	cd $(FT_DIR) && $(MAKE) clean


