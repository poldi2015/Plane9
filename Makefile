DOCS=Plane9 Players
CHAPTERS=$(wildcard [a-z]*.tex)

.PHONY: all clean

default: all

all: $(patsubst %,%.pdf,$(DOCS))

%.pdf : %.tex $(CHAPTERS)
	latexmk -latexoption=-interaction=nonstopmode -latexoption=-halt-on-error -pdf $<

clean:
	latexmk -c
	touch $(patsubst %,%.tex,$(DOCS))
