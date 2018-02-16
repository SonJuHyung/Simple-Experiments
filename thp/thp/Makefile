#
#	DKU Operating System Lab
#	    Lab1 (Scheduler Algorithm Simulator)
#	    Student id : 
#	    Student name : 
#
#   Makfeile :
#       - Makefile for lab1 compilation.
#

CC = gcc
INC = -I${CURDIR}/include/
CFLAGS = -g $(INC) -fms-extensions

OBJS_THP_TEST = thp_test.o 
OBJS_THP_DATA = thp_data.o

SRCS=$(OBJS_THP_TEST:.o=.c) $(OBJS_THP_DATA:.o=.c)

TARGET_THP_TEST = thp_test 
TARGET_THP_DATA = thp_data

.SUFFIXES : .c .o

.c.o:
	@echo "Compilingi thp test $< ..."
	$(CC) -c $(CFLAGS) -o $@ $<

$(TARGET_THP_TEST) : $(OBJS_THP_TEST)
	$(CC) -o $(TARGET_THP_TEST) $(OBJS_THP_TEST)

$(TARGET_THP_DATA) : $(OBJS_THP_DATA)
	$(CC) -o $(TARGET_THP_DATA) $(OBJS_THP_DATA)

all : $(TARGET_THP_TEST) $(TARGET_THP_DATA)

dep : 
	gccmaedep $(INC) $(SRCS)

clean :
	@echo "Cleaning thp test $< ..."
	rm -rf $(OBJS_THP_TEST) $(TARGET_THP_TEST) 
	rm -rf $(OBJS_THP_DATA) $(TARGET_THP_DATA) 

new :
	$(MAKE) clean
	$(MAKE)
