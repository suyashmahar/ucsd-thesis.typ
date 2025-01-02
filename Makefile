all:
	typst compile  -j$(shell nproc) main.typ example.pdf

clean:
	rm example.pdf
