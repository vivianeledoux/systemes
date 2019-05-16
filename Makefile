all: a.out
	./a.out

a.out : interface.cmi impl_trivial.cmo main.cmo
	ocamlc -o a.out -thread unix.cma threads.cma impl_triviale.cmo main.cmo

main.cmo : interface.cmi impl_trivial.cmo main.ml
	ocamlc -c main.ml

impl_trivial.cmo: interface.cmi impl_triviale.ml
	ocamlc -c -thread unix.cma threads.cma impl_triviale.ml

interface.cmi: interface.mli
	ocamlc -c interface.mli

clean:
	rm -f *.cm[io]
	rm -f a.out
