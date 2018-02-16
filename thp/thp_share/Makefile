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

OBJS_THP_TEST = thp_share_test.o 

SRCS=$(OBJS_THP_TEST:.o=.c)

TARGET_THP_TEST = thp_share_test 

.SUFFIXES : .c .o

.c.o:
	@echo "Compilingi thp test $< ..."
	$(CC) -c $(CFLAGS) -o $@ $<

$(TARGET_THP_TEST) : $(OBJS_THP_TEST)
	$(CC) -o $(TARGET_THP_TEST) $(OBJS_THP_TEST)

all : $(TARGET_THP_TEST)

dep : 
	gccmaedep $(INC) $(SRCS)

clean :
	@echo "Cleaning thp test $< ..."
	rm -rf $(OBJS_THP_TEST) $(TARGET_THP_TEST) 

new :
	$(MAKE) clean
	$(MAKE)
