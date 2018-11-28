# jinja2 rule
#GENFILES = $($(basename $(TEMPLATES)):templates/%=%)

_GENFILES = $(basename $(TEMPLATES))
GENFILES = $(_GENFILES:templates/%=%)

$(GENFILES): %: templates/%.in $(MKFILES) tools/jinja2-cli.py
	ORG=$(ORG) CONSORTIUM=$(CONSORTIUM) DOMAIN=$(DOMAIN) tools/jinja2-cli.py < $< > $@ || (rm -f $@; false)
