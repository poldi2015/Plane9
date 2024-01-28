BOOK=Plane9
DOCS=$(BOOK) Players
CHAPTERS=$(wildcard [a-z-]*.tex) \
		 $(wildcard content/[a-z-]*.tex) \
		 $(wildcard lib/[a-z-]*.sty)

PYTHON=python3
PDF2PRINT=lib/pdf2print.py

.PHONY: all print clean

default: all

all: $(patsubst %,%.pdf,$(DOCS))

%.pdf : %.tex $(CHAPTERS)
	latexmk -synctex=1 -interaction=nonstopmode -halt-on-error $<

print : $(BOOK)_print.pdf

$(BOOK)_print.pdf : $(BOOK).pdf
	$(PYTHON) $(PDF2PRINT) $< $@ -W 3 -H 3 -P 0

clean:
	latexmk -CA	
	rm $(BOOK)_print.pdf
	touch $(patsubst %,%.tex,$(DOCS))
