TITLE = foo

RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)"

LATEX = pdflatex --shell-escape -interaction=nonstopmode

all: $(TITLE).pdf

web: $(TITLE)-web.pdf

%.aux %.log: %.tex
	$(LATEX) $<

%.bbl: %.bib %.aux
	bibtex $(<:%.bib=%)

%.pdf: %.tex %.bbl
	$(LATEX) $<
	egrep $(RERUN) $(<:%.tex=%.log) && $(LATEX) $<; true
	egrep $(RERUN) $(<:%.tex=%.log) && $(LATEX) $<; true

# We need to save the original metadata and restoring after passing through
# Ghostscript due to a bug.
#
# http://bugs.ghostscript.com/show_bug.cgi?id=693400
%.docinfo: %.pdf
	pdftk $^ dump_data_utf8 output $@

%-web.pdf: %.pdf %.docinfo
	gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -sOutputFile=$@.tmp -dNOPAUSE -dBATCH $<
	pdftk $@.tmp update_info_utf8 $(<:%.pdf=%.docinfo) output $@
	rm -f $@.tmp

%.d: %.tex deps
	./deps $<

clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.pdf *.d *.docinfo

include $(TITLE).d

.PHONY: all web clean
