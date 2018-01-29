all: clean main.html

clean:
	rm -f main.html

main.html: main.md
	cat slide-head.html >$@
	# sed -e 's/&/\&amp\;/g; s/</\&lt\;/g; s/>/\&gt\;/g' $< >>$@
	cat $< >>$@
	cat slide-bottom.html >>$@
