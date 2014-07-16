TITLE = foo

RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)"

LATEX = pdflatex --shell-escape -interaction=nonstopmode

all: $(TITLE).pdf

%.aux %.log: %.tex
	$(LATEX) $<

%.bbl: %.bib %.aux
	bibtex $(<:%.bib=%)

%.pdf: %.tex %.bbl
	$(LATEX) $<
	egrep $(RERUN) $(<:%.tex=%.log) && $(LATEX) $<; true
	egrep $(RERUN) $(<:%.tex=%.log) && $(LATEX) $<; true

%.d: %.tex deps
	./deps $<

clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.pdf *.d

include $(TITLE).d

.PHONY: all clean
