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
printlegacy : $(BOOK)_legacyprint.pdf

%.pdf : %.tex $(CHAPTERS)
	latexmk -synctex=1 -interaction=nonstopmode -halt-on-error $<

$(BOOK)_legacyprint.pdf $(BOOK)_front.pdf $(BOOK)_front.png &: $(BOOK)_letter.pdf
	$(PYTHON) $(PDF2PRINT) $< $(BOOK)_legacyprint.pdf $(BOOK)_front.pdf $(BOOK)_back.pdf \
		--pdfbackground lib/images/print_background.pdf \
		--margin_inner 10 --margin_outer 3 --margin_height 3 \
		--skip_page 0 --skip_page -1 \
		--white_page 1 --white_page 2 --white_page 3 --white_page 6 --white_page 143
	$(PYTHON) $(PDF2PRINT) $< $(BOOK)_legacyprint_guides.pdf \
		--pdfbackground lib/images/print_background_guides.pdf \
		--margin_inner 10 --margin_outer 3 --margin_height 3 \
		--skip_page 0 --skip_page -1 \
		--white_page 1 --white_page 2 --white_page 3 --white_page 6 --white_page 143		
	pdftoppm -r 300 -png $(BOOK)_front.pdf > $(BOOK)_front.png
	pdftoppm -r 300 -png $(BOOK)_back.pdf > $(BOOK)_back.png

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