TARGET=bgp_next_hop

default: compile

compile:
	latexmk -pdf

clean:
	rm -rf _minted-*/
	latexmk -c

draw:
	dot -Tpng images/$(TARGET).dot -o images/$(TARGET).png