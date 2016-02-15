.PHONY: clean

CC=gcc
CFLAGS=-lfl

htmltoken:htmltoken.cc
	$(CC) -o$@ $< $(CFLAGS)

htmltoken.cc:html.flex
	flex -o$@ $<

dotest:htmltoken example_1.html
	./$< example_1.html

clean:
	rm htmltoken.cc htmltoken
