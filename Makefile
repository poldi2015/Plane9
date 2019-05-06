DOCS=Abyssum Players
CHAPTERS=$(wildcard [a-z]*.tex)

.PHONY: all clean

default: all

all: $(patsubst %,%.pdf,$(DOCS))

%.pdf : %.tex $(CHAPTERS)
	latexmk -pdf $<

clean:
	latexmk -c
	touch $(patsubst %,%.tex,$(DOCS))
