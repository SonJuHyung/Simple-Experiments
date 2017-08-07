
CC = gcc
INC = -I$(CURDIR)/include/
CFLAGS = -g $(INC)
LDFLAGS = -lpthread

OBJS_CLS = struct_cache_line.o 

SRCS = $(OBJS_CLS:.o=.c)

TARGET_CLS = sync_spl 

.SUFFIXES : .c .o

.c.o:
	@echo "Compiling Experiment :  $< ..."
	$(CC) -c $(CFLAGS) -o $@ $<

$(TARGET_CLS) : $(OBJS_CLS)
	@echo "Start building...  Cache line fitting exepriment... " 
	$(CC) -o $(TARGET_CLS) $(OBJS_CLS) $(LDFLAGS)
	@echo "Build done."

all : $(TARGET_CLS)

dep : 
	gccmaedep $(INC) $(SRCS)

clean :
	@echo "Cleaning  $< ..."
	rm -rf $(OBJS_CLS)
	rm -rf $(TARGET_CLS)

new :
	$(MAKE) clean
	$(MAKE)
