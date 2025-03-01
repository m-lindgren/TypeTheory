# -*- makefile-gmake -*-
UMAKEFILES += Makefile
ifneq "$(INCLUDE)" "no"
ifeq ($(shell test -f build/Makefile-configuration && echo yes),yes)
UMAKEFILES += build/Makefile-configuration
include build/Makefile-configuration
endif
endif
############################################
# The packages, listed in order by dependency:
PACKAGES += Auxiliary
PACKAGES += RelUniv
PACKAGES += CompCats
PACKAGES += TypeCat
PACKAGES += CwF
PACKAGES += CwF_TypeCat
PACKAGES += CwDM
PACKAGES += TypeCat_CompCat
PACKAGES += OtherDefs
PACKAGES += Categories
PACKAGES += Instances
PACKAGES += Csystems
PACKAGES += Bsystems
PACKAGES += Cubical
PACKAGES += Initiality
PACKAGES += TypeConstructions
PACKAGES += Articles
############################################
# other user options; see also build/Makefile-configuration-template
BUILD_COQ ?= no 
BUILD_COQIDE ?= no
COQBIN ?=
############################################
.PHONY: all everything install lc lcp wc describe clean distclean build-coq doc build-coqide
COQIDE_OPTION ?= no
ifeq "$(BUILD_COQ)" "yes"
COQBIN=sub/coq/bin/
all: build-coq
build-coq: sub/coq/bin/coqc
ifeq "$(BUILD_COQIDE)" "yes"
all: build-coqide
build-coqide: sub/coq/bin/coqide
COQIDE_OPTION := opt
LABLGTK := -lablgtkdir "$(shell pwd)"/sub/lablgtk/src
endif
endif

# override the definition in build/CoqMakefile.make, to eliminate the -utf8 option
COQDOC := coqdoc
COQDOCFLAGS := -interpolate --charset utf-8
COQDOC_OPTIONS := -toc $(COQDOCFLAGS) $(COQDOCLIBS) -utf8

PACKAGE_FILES := $(patsubst %, TypeTheory/%/.package/files, $(PACKAGES))

ifneq "$(INCLUDE)" "no"
include build/CoqMakefile.make
endif
everything: all html install
OTHERFLAGS += $(MOREFLAGS)
OTHERFLAGS += -noinit -indices-matter -type-in-type -w none
ifeq ($(VERBOSE),yes)
OTHERFLAGS += -verbose
endif
ENHANCEDDOCTARGET = enhanced-html
ENHANCEDDOCSOURCE = util/enhanced-doc
LATEXDIR = latex
COQDOCLATEXOPTIONS := -latex -utf8 --body-only

DEFINERS := 
DEFINERS := $(DEFINERS)Axiom\|
DEFINERS := $(DEFINERS)Class\|
DEFINERS := $(DEFINERS)CoFixpoint\|
DEFINERS := $(DEFINERS)CoInductive\|
DEFINERS := $(DEFINERS)Corollary\|
DEFINERS := $(DEFINERS)Definition\|
DEFINERS := $(DEFINERS)Example\|
DEFINERS := $(DEFINERS)Fact\|
DEFINERS := $(DEFINERS)Fixpoint\|
DEFINERS := $(DEFINERS)Function\|
DEFINERS := $(DEFINERS)Identity[[:space:]]+Coercion\|
DEFINERS := $(DEFINERS)Inductive\|
DEFINERS := $(DEFINERS)Instance\|
DEFINERS := $(DEFINERS)Lemma\|
DEFINERS := $(DEFINERS)Ltac\|
DEFINERS := $(DEFINERS)Module[[:space:]]+Import\|
DEFINERS := $(DEFINERS)Module\|
DEFINERS := $(DEFINERS)Notation\|
DEFINERS := $(DEFINERS)Proposition\|
DEFINERS := $(DEFINERS)Record\|
DEFINERS := $(DEFINERS)Remark\|
DEFINERS := $(DEFINERS)Scheme[[:space:]]+Equality[[:space:]]+for\|
DEFINERS := $(DEFINERS)Scheme[[:space:]]+Induction[[:space:]]+for\|
DEFINERS := $(DEFINERS)Scheme\|
DEFINERS := $(DEFINERS)Structure\|
DEFINERS := $(DEFINERS)Theorem

MODIFIERS := 
MODIFIERS := $(MODIFIERS)Canonical\|
MODIFIERS := $(MODIFIERS)Global\|
MODIFIERS := $(MODIFIERS)Local\|
MODIFIERS := $(MODIFIERS)Private\|
MODIFIERS := $(MODIFIERS)Program\|

COQDEFS := --language=none												\
	-r '/^[[:space:]]*\(\($(MODIFIERS)\)[[:space:]]+\)?\($(DEFINERS)\)[[:space:]]+\([[:alnum:]'\''_]+\)/\4/'	\
	-r "/^[[:space:]]*Notation.* \"'\([[:alnum:]]+\)'/\1/"								\
	-r '/^[[:space:]]*Tactic Notation.* "\([[:alnum:]]+\)" /\1/'

$(foreach P,$(PACKAGES),$(eval TAGS-$P: $(filter TypeTheory/$P/%,$(VFILES)); etags -o $$@ $$^))
$(VFILES:.v=.vo) : # $(COQBIN)coqc
TAGS : $(PACKAGE_FILES) $(VFILES); etags $(COQDEFS) $(VFILES)
FILES_FILTER := grep -vE '^[[:space:]]*(\#.*)?$$'
$(foreach P,$(PACKAGES),$(eval $P: $(shell <TypeTheory/$P/.package/files $(FILES_FILTER) |sed "s=^\(.*\)=TypeTheory/$P/\1o=" )))
install:all
coqwc:; coqwc $(VFILES)
lc:; wc -l $(VFILES)
lcp:; for i in $(PACKAGES) ; do echo ; echo ==== $$i ==== ; for f in $(VFILES) ; do echo "$$f" ; done | grep "TypeTheory/$$i" | xargs wc -l ; done
wc:; wc -w $(VFILES)
admitted: 
	grep --color=auto Admitted $(VFILES)
axiom:
	grep --color=auto "Axiom " $(VFILES)
describe:; git describe --dirty --long --always --abbrev=40 --all
.coq_makefile_input: $(PACKAGE_FILES) $(UMAKEFILES)
	@ echo making $@ ; ( \
	echo '# -*- makefile-gmake -*-' ;\
	echo ;\
	echo '# DO NOT EDIT THIS FILE!' ;\
	echo '# It is made by automatically (by code in Makefile)' ;\
	echo ;\
	echo '-Q TypeTheory TypeTheory' ;\
	echo '-arg "$(OTHERFLAGS)"' ;\
	echo ;\
	for i in $(PACKAGES) ;\
	do <TypeTheory/$$i/.package/files $(FILES_FILTER) |sed "s=^=TypeTheory/$$i/="  ;\
	done ;\
	echo ;\
	echo '# Local ''Variables:' ;\
	echo '# compile-command: "coq_makefile -f .coq_makefile_input -o CoqMakefile.make.tmp && mv CoqMakefile.make.tmp build/CoqMakefile.make"' ;\
	echo '# End:' ;\
	) >$@
# the '' above prevents emacs from mistaking the lines above as providing local variables when visiting this file
build/CoqMakefile.make: .coq_makefile_input 
	$(COQBIN)coq_makefile -f .coq_makefile_input -o .coq_makefile_output
	mv .coq_makefile_output $@

# "clean::" occurs also in build/CoqMakefile.make, hence both colons
clean::
	rm -f .coq_makefile_input .coq_makefile_output build/CoqMakefile.make
	find TypeTheory \( -name .\*.aux -o -name \*.glob -o -name \*.v.d -o -name \*.vo -o -name \*.vos -o -name \*.vok \) -delete
	find TypeTheory -type d -empty -delete
clean::; rm -rf $(ENHANCEDDOCTARGET)
latex-clean clean::; rm -rf $(LATEXDIR)

distclean:: clean
distclean::          ; - $(MAKE) -C sub/coq distclean
distclean::          ; rm -f build/Makefile-configuration

# building coq:
export PATH:=$(shell pwd)/sub/coq/bin:$(PATH)
sub/lablgtk/README:
	git submodule update --init sub/lablgtk
sub/coq/configure sub/coq/configure.ml:
	git submodule update --init sub/coq
ifeq "$(BUILD_COQ) $(BUILD_COQIDE)" "yes yes"
sub/coq/config/coq_config.ml: sub/lablgtk/src/gSourceView2.cmi
endif
sub/coq/config/coq_config.ml: sub/coq/configure sub/coq/configure.ml
	: making $@ because of $?
	cd sub/coq && ./configure -coqide "$(COQIDE_OPTION)" $(LABLGTK) -with-doc no -annotate -debug -local
# instead of "coqlight" below, we could use simply "theories/Init/Prelude.vo"
#sub/coq/bin/coq_makefile sub/coq/bin/coqc: sub/coq/config/coq_config.ml
.PHONY: rebuild-coq
rebuild-coq sub/coq/bin/coq_makefile sub/coq/bin/coqc:
	$(MAKE) -w -C sub/coq KEEP_ML4_PREPROCESSED=true VERBOSE=true READABLE_ML4=yes coqbinaries tools states
sub/coq/bin/coqide: sub/lablgtk/README sub/coq/config/coq_config.ml
	$(MAKE) -w -C sub/coq KEEP_ML4_PREPROCESSED=true VERBOSE=true READABLE_ML4=yes coqide-binaries bin/coqide
configure-coq: sub/coq/config/coq_config.ml
# we use sub/lablgtk/src/gSourceView2.cmi as a proxy for all of lablgtk
# note: under Mac OS X, "homebrew" installs lablgtk without that file, but it's needed for building coqide.  That's why we build lablgtk ourselves.
# note: lablgtk needs camlp4, not camlp5.  Strange, but it does.  So we must install that, too.
build-lablgtk sub/lablgtk/src/gSourceView2.cmi: sub/lablgtk/README
	cd sub/lablgtk && ./configure
	$(MAKE) -C sub/lablgtk all byte opt world
git-describe:
	git describe --dirty --long --always --abbrev=40
	git submodule foreach git describe --dirty --long --always --abbrev=40 --tags
doc: $(GLOBFILES) $(VFILES) 
	mkdir -p $(ENHANCEDDOCTARGET)
	cp $(ENHANCEDDOCSOURCE)/proofs-toggle.js $(ENHANCEDDOCTARGET)/proofs-toggle.js
	$(COQDOC) -toc $(COQDOCFLAGS) -html $(COQDOCLIBS) -d $(ENHANCEDDOCTARGET) \
	--with-header $(ENHANCEDDOCSOURCE)/header.html $(VFILES)
	sed -i'.bk' -f $(ENHANCEDDOCSOURCE)/proofs-toggle.sed $(ENHANCEDDOCTARGET)/*html

# Jason Gross' coq-tools bug isolator:
# The isolated bug will appear in this file, in the TypeTheory directory:
ISOLATED_BUG_FILE := isolated_bug.v
# To use it, run something like this command in an interactive shell:
#     make isolate-bug BUGGY_FILE=Foundations/PartB.v
sub/coq-tools/find-bug.py:
	git submodule update --init sub/coq-tools
help-find-bug:
	sub/coq-tools/find-bug.py --help
isolate-bug: sub/coq-tools/find-bug.py
	cd UniMath && \
	rm -f $(ISOLATED_BUG_FILE) && \
	../sub/coq-tools/find-bug.py --coqbin ../sub/coq/bin -R . UniMath \
		--arg " -indices-matter" \
		--arg " -type-in-type" \
		$(BUGGY_FILE) $(ISOLATED_BUG_FILE)
	@ echo "==="
	@ echo "=== the isolated bug has been deposited in the file UniMath/$(ISOLATED_BUG_FILE)"
	@ echo "==="

world: all html doc latex-doc

latex-doc: $(LATEXDIR)/doc.pdf

$(LATEXDIR)/doc.pdf : $(LATEXDIR)/helper.tex $(LATEXDIR)/references.bib $(LATEXDIR)/latex-preamble.txt $(LATEXDIR)/helper.tex $(LATEXDIR)/latex-epilogue.txt
	cd $(LATEXDIR) && cat latex-preamble.txt helper.tex latex-epilogue.txt > doc.tex
	cd $(LATEXDIR) && latexmk -pdf doc

$(LATEXDIR)/coqdoc.sty $(LATEXDIR)/helper.tex : $(VFILES:.v=.glob) $(VFILES)
	$(COQDOC) -Q TypeTheory TypeTheory $(COQDOC_OPTIONS) $(COQDOCLATEXOPTIONS) $(VFILES) -o $@

.PHONY: enforce-max-line-length
enforce-max-line-length:
	LC_ALL="en_US.UTF-8" gwc -L $(VFILES) | grep -vw total | awk '{ if ($$1 > 100) { printf "%6d  %s\n", $$1, $$2 }}' | sort -r | grep .
show-long-lines:
	LC_ALL="en_US.UTF-8" grep -nE '.{101}' $(VFILES)

#################################
# targets best used with INCLUDE=no
git-clean:
	git clean -Xdfq
	git submodule foreach git clean -xdfq
git-deinit:
	git submodule foreach git clean -xdfq
	git submodule deinit -f sub/*
#################################
