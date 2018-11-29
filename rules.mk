# jinja2 rule
#GENFILES = $($(basename $(TEMPLATES)):templates/%=%)

_GENFILES = $(basename $(TEMPLATES))
GENFILES = $(_GENFILES:templates/%=%)

$(GENFILES): %: templates/%.in $(MKFILES) tools/jinja2-cli.py .env
	env $$(cat .env | xargs) tools/jinja2-cli.py < $< > $@ || (rm -f $@; false)

all: $(GENFILES)
