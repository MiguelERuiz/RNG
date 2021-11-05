TARGET=apuntes.tex
PDF=apuntes.pdf

all: 
	compile
	view


compile: 
	pdflatex -shell-escape $(TARGET)

view: 
	evince $(PDF) &

