# Base directory for translation files
LOCALEDIR = locales
# Python file or directory containing the source code
SOURCE = bot/bot.py
# Languages to translate into
LANGUAGES = en fr tr de

# Default target to start all processes
.PHONY: all create-translation-files update-translations clean

all: create-translation-files

# Target to create .po and .mo files
create-translation-files: $(LANGUAGES)

$(LANGUAGES):
	@echo "Creating and updating translation files for: $@"
	@mkdir -p $(LOCALEDIR)/$@/LC_MESSAGES
	# Create .pot file
	@xgettext -d base -o $(LOCALEDIR)/base.pot --from-code=UTF-8 -L Python $(SOURCE)
	# Check if .po file exists, then update or create .po file
	@if [ -f $(LOCALEDIR)/$@/LC_MESSAGES/base.po ]; then \
		msgmerge --update --backup=none --no-fuzzy-matching $(LOCALEDIR)/$@/LC_MESSAGES/base.po $(LOCALEDIR)/base.pot; \
	else \
		msginit --no-translator --input=$(LOCALEDIR)/base.pot --output-file=$(LOCALEDIR)/$@/LC_MESSAGES/base.po --locale=$@_UTF-8; \
	fi
	# Compile .mo file
	@msgfmt $(LOCALEDIR)/$@/LC_MESSAGES/base.po -o $(LOCALEDIR)/$@/LC_MESSAGES/base.mo


# Target to update existing .po files with newly added texts
update-translations: 
	@xgettext -d base -o $(LOCALEDIR)/base.pot --from-code=UTF-8 -L Python $(SOURCE)
	@$(foreach lang,$(LANGUAGES),msgmerge --update --backup=none --no-fuzzy-matching $(LOCALEDIR)/$(lang)/LC_MESSAGES/base.po $(LOCALEDIR)/base.pot;)

# Target to clean up generated files
clean:
	@rm -f $(LOCALEDIR)/*/LC_MESSAGES/base.mo
	@rm -f $(LOCALEDIR)/base.pot
	@echo "Cleanup done."

# Target to generate .mo files from .po files for all languages
regenerate-mo: create-translation-files
	@$(foreach lang,$(LANGUAGES), \
		echo "Generating .mo file for: $(lang)"; \
		mkdir -p $(LOCALEDIR)/$(lang)/LC_MESSAGES; \
		msgfmt $(LOCALEDIR)/$(lang)/LC_MESSAGES/base.po -o $(LOCALEDIR)/$(lang)/LC_MESSAGES/base.mo; \
	)
# Read the docker compose logs
logs:
	@docker compose logs -f --tail=500