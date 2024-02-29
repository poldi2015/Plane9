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

$(BOOK)_print.pdf $(BOOK)_front.pdf $(BOOK)_front.png &: $(BOOK).pdf
	$(PYTHON) $(PDF2PRINT) $< $(BOOK)_print.pdf $(BOOK)_front.pdf $(BOOK)_back.pdf -W 3 -H 3 -P 0
	pdftoppm -png $(BOOK)_front.pdf > $(BOOK)_front.png
	pdftoppm -png $(BOOK)_back.pdf > $(BOOK)_back.png

clean:
	latexmk -CA	
	rm -f $(BOOK)_print.pdf
	touch $(patsubst %,%.tex,$(DOCS))
