all: getwork.c 
	gcc -g -pthread -Wall -std=c99 -o getwork getwork.c curl/curl.h jansson/jansson.h

clean:
	$(RM) getwork.o getwork
