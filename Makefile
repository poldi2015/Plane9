DOCS=Plane9 Players
CHAPTERS=$(wildcard [a-z-]*.tex) \
		 $(wildcard lib/[a-z-]*.sty)

.PHONY: all clean

default: all

all: $(patsubst %,%.pdf,$(DOCS))

%.pdf : %.tex $(CHAPTERS)
	latexmk -synctex=1 -interaction=nonstopmode -halt-on-error $<

clean:
	latexmk -CA	
	touch $(patsubst %,%.tex,$(DOCS))
