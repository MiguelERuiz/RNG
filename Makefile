
default: compile

compile:
	latexmk -pdf

clean:
	rm -rf _minted-*/
	latexmk -c