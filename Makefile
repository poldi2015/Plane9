BOOK=Plane9
DOCS=$(BOOK) Players
CHAPTERS=$(wildcard [a-z-]*.tex) \
		 $(wildcard content/[a-z-]*.tex) \
		 $(wildcard lib/[a-z-]*.sty)

PYTHON=python3
PDF2PRINT=lib/pdf2print.py

.PHONY: all print letter letter_print printlegacy clean cmykconvert

default: all

all: $(patsubst %,%.pdf,$(DOCS))
print : $(BOOK)_print.pdf
letter : $(BOOK)_letter.pdf
letter_print : $(BOOK)_letter_print.pdf
amazon : $(BOOK)_amazon.pdf
amazon_print : $(BOOK)_amazon_print.pdf
printlegacy : $(BOOK)_legacyprint.pdf
printlegacy_letter : $(BOOK)_legacyprint_letter.pdf
printlegacy_amazon : $(BOOK)_legacyprint_amazon.pdf

%.pdf : %.tex $(CHAPTERS)
	latexmk -synctex=1 -interaction=nonstopmode -halt-on-error $<

$(BOOK)_legacyprint.pdf $(BOOK)_front.pdf $(BOOK)_front.png &: $(BOOK).pdf
	$(PYTHON) $(PDF2PRINT) $< $(BOOK)_legacyprint.pdf $(BOOK)_front.pdf $(BOOK)_back.pdf \
		--pdfbackground lib/images/print_background.pdf \
		--margin_inner 10 --margin_outer 3 --margin_height 3 \
		--skip_page 0 --skip_page -1 \
		--white_page 1 --white_page 2 --white_page 3 --white_page 6 --white_page 143
	pdftoppm -r 300 -png $(BOOK)_front.pdf > $(BOOK)_front.png
	pdftoppm -r 300 -png $(BOOK)_back.pdf > $(BOOK)_back.png	

$(BOOK)_legacyprint_letter.pdf $(BOOK)_front_letter.pdf $(BOOK)_front_letter.png &: $(BOOK)_letter.pdf
	$(PYTHON) $(PDF2PRINT) $< $(BOOK)_legacyprint_letter.pdf $(BOOK)_front_letter.pdf $(BOOK)_back_letter.pdf \
		--pdfbackground lib/images/print_background.pdf \
		--margin_inner 10 --margin_outer 3 --margin_height 3 \
		--skip_page 0 --skip_page -1 \
		--white_page 1 --white_page 2 --white_page 3 --white_page 6 --white_page 143
	pdftoppm -r 300 -png $(BOOK)_front_letter.pdf > $(BOOK)_front_letter.png
	pdftoppm -r 300 -png $(BOOK)_back_letter.pdf > $(BOOK)_back_letter.png

$(BOOK)_legacyprint_amazon.pdf $(BOOK)_front_amazon.pdf $(BOOK)_front_amazon.png &: $(BOOK)_amazon.pdf
	$(PYTHON) $(PDF2PRINT) $< $(BOOK)_legacyprint_amazon.pdf $(BOOK)_front_amazon.pdf $(BOOK)_back_amazon.pdf \
		--pdfbackground lib/images/print_background.pdf \
		--margin_inner 10 --margin_outer 3 --margin_height 3 \
		--skip_page 0 --skip_page -1 \
		--white_page 1 --white_page 2 --white_page 3 --white_page 6 --white_page 143
	pdftoppm -r 300 -png $(BOOK)_front_amazon.pdf > $(BOOK)_front_amazon.png
	pdftoppm -r 300 -png $(BOOK)_back_amazon.pdf > $(BOOK)_back_amazon.png	

cmykconvert: $(patsubst images/%.jpg,images/cmyk/%_cmyk.jpg,$(wildcard images/*.jpg)) $(patsubst images/%.png,images/cmyk/%_cmyk.jpg,$(wildcard images/*.png))
	
images/cmyk/%_cmyk.jpg : images/%.jpg
	mkdir -p images/cmyk
	convert $< -colorspace cmyk -profile lib/colorprofiles/ECI_Offset_2009/ISOcoated_v2_eci.icc $@

images/cmyk/%_cmyk.jpg : images/%.png
	mkdir -p images/cmyk
	convert $< -colorspace cmyk -profile lib/colorprofiles/ECI_Offset_2009/ISOcoated_v2_eci.icc $@	

clean:
	latexmk -CA	
	rm -f $(BOOK)_print.pdf
	touch $(patsubst %,%.tex,$(DOCS))	