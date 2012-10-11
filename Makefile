PARSE=xmllint
PARSEFLAGS=--html --xmlout
TOHTML=xmllint --html
HG=hg
HGFLAGS=
CURL=curl
CURLFLAGS=-R
UNZIP=unzip
UNZIP_FLAGS=
# The following is a specially modified version of trang that
# instead of generating RNC output as plain text, generates RNC
# output that's marked up as HTML, with hyperlinks, etc.
TRANG=$(JAVA) $(JAVAFLAGS) -jar tools/trang.jar 
TRANGFLAGS=
XSLTPROC=xsltproc
XSLTPROCFLAGS=--novalid
INCELIM=incelim
INCELIMFLAGS=-xsltproc
PERL=perl
PERLFLAGS=
GREP=grep
GREPFLAGS=
HEAD=head
HEADFLAGS=
PATCH=patch
PATCHFLAGS=-N -p0
JAVA=java
JAVAFLAGS=
SCP=scp
SCPFLAGS=
CVS=cvs
CVSFLAGS=
HTML2MARKDOWN=html2text
HTML2MARKDOWNFLAGS=

INCELIM_DIR=tools/rng-incelim-1.2
WHATTF_BASE_URL=http://svn.versiondude.net/whattf/syntax/trunk/relaxng/
OTHER_RNG=$(foreach rnc,$(wildcard syntax/relaxng/*.rnc),$(basename $(notdir $(rnc))).rng)
ARIA_OTHER_RNG=$(foreach rnc,$(wildcard syntax/relaxng/*.rnc),aria/$(basename $(notdir $(rnc))).rng)
SCHEMA_FILES=$(wildcard syntax/relaxng/*.rnc) syntax/relaxng/assertions.sch syntax/relaxng/LICENSE
MULTIPAGE_SPEC_FILES=$(foreach file,$(wildcard html5/*.html),$(notdir $(file)))

ELEMENTS=$(wildcard elements/*.html)

ifneq ($(SHOW_CONTENT_MODELS),1)
SHOW_CONTENT_MODELS=0
endif

ifeq ($(PUBSITE),)
PUBSITE=W3C
endif

all: syntax Overview.html index.html MANIFEST spec.html README.markdown

debug:
	@echo $(MULTIPAGE_SPEC_FILES)

patch-schema: $(SCHEMA_FILES)
	$(HG) --cwd syntax $(HGFLAGS) diff -X "relaxng/datatype/java*" relaxng > $@

html.rng: $(SCHEMA_FILES)
	$(TRANG) $(TRANGFLAGS) html.rnc $@

html-compiled.rng: html.rng
	INCELIM=$(realpath $(INCELIM_DIR)) sh $(INCELIM_DIR)/$(INCELIM) $(INCELIMFLAGS) $<

html-compiled.rng.combined: html-compiled.rng tools/combine.xsl tools/strip-comments.xsl
	$(XSLTPROC) $(XSLTPROCFLAGS) tools/combine.xsl $< \
	  | $(XSLTPROC) $(XSLTPROCFLAGS) tools/strip-comments.xsl - > $@

schema.html: html-compiled.rng.combined
	$(JAVA) $(JAVAFLAGS) -jar tools/trang.jar -I rng -O rnc $< $@
#	$(CURL) $(CURLFLAGS) -F "rngfile=@$(realpath $<);type=text/html" $(TRANG_HTML_SPEC_CGI) -o $@
	$(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s/\s+<a[^<]+<\/a> notAllowed//g' $@

LICENSE.xml: syntax/relaxng/LICENSE
	echo "<license>" > $@
	$(PERL) $(PERLFLAGS) -p -e "s/&/&amp;/g" $< | $(PERL) $(PERLFLAGS) -p -e "s/</&lt;/g" >> $@
	echo "</license>" >> $@

html.css:
	$(CURL) $(CURLFLAGS) -o html.css http://svn.webkit.org/repository/webkit/trunk/Source/WebCore/css/html.css
	$(PATCH) $(PATCHFLAGS) < patch-css

html.css.LICENSE.xml: html.css
	echo "<license>" > $@
	head -n20 $< | tail -n17 | cut -c4- >> $@
	echo "</license>" >> $@

html.css.xml: html.css tools/css2xml
	./tools/css2xml $< > $@

fragment-links.js:
	wget http://dev.w3.org/html5/spec-author-view/fragment-links.js
	#$(CURL) $(CURLFLAGS) -o $@ http://dev.w3.org/html5/spec-author-view/fragment-links.js
#	$(CURL) $(CURLFLAGS) -o $@ http://developers.whatwg.org/fragment-links.js

fragment-links.html: fragment-links.js
	$(GREP) $(GREPFLAGS) "var fragment_links" $< \
	  | perl -pe "s|var fragment_links = \{ '|<div>\n<ul>\n<li>#|" \
	  | perl -pe "s|':'|</li>\n<li>|g" \
	  | perl -pe "s|','|</li>\n</ul>\n<ul>\n<li>#|g" \
	  | perl -pe "s|' };|</li>\n</ul>\n</div>|g" \
	  > $@

fragment-links-full.js: /opt/workspace/github-html/heartbeat/fragment-links.js
	cp $< $@
	#$(CURL) $(CURLFLAGS) -o $@ http://dev.w3.org/html5/spec/fragment-links.js

fragment-links-full.html: fragment-links-full.js
	$(GREP) $(GREPFLAGS) "var fragment_links" $< \
	  | perl -pe "s|var fragment_links = \{ '|<div>\n<ul>\n<li>#|" \
	  | perl -pe "s|':'|</li>\n<li>|g" \
	  | perl -pe "s|','|</li>\n</ul>\n<ul>\n<li>#|g" \
	  | perl -pe "s|' };|</li>\n</ul>\n</div>|g" \
	  > $@

elements/h2.html elements/h3.html elements/h4.html elements/h5.html elements/h6.html: elements/h1.html
	cp $< $@

html.spec.src.html: html-compiled.rng schema.html \
  tools/generate-spec-source.xsl syntax/relaxng/assertions.sch \
  src/head.html src/header.src.html src/intro-scope.html \
  src/terms.html src/syntax.html src/documents.html \
  $(ELEMENTS) src/attributes.html src/map-attributes.html \
  src/datatypes.html src/references.html src/elements-by-function.html \
  html5-spec fragment-links.html fragment-links-full.html \
  LICENSE.xml html.css.xml html.css.LICENSE.xml
	$(XSLTPROC) $(XSLTPROCFLAGS) \
	  --param show-content-models $(SHOW_CONTENT_MODELS) \
	  tools/generate-spec-source.xsl $< \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|(Use CSS instead). (http://wiki.whatwg.org/wiki/Presentational_elements_and_attributes)|<a href="$$2">$$1</a>.|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|(guidance\s+on\s+providing\s+text\s+alternatives\s+for\s+images).\s+(http://www.w3.org/wiki/HTML/Usage/TextAlternatives)|<a href="$$2">$$1</a>.|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|(meta extensions). &lt;(http://wiki.whatwg.org/wiki/MetaExtensions)&gt;|<a href="$$2">$$1</a>.|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|d:string ""|"" <span class="attr-qualifier">(empty string)</span> <span class="postfix or">or</span> <a href="#syntax-attr-empty">empty</a>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|d:string||g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>shape.rect</a>|>shape</a>=<span class="attr-values">"rect"</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>shape.circle</a>|>shape</a>=<span class="attr-values">"circle"</span><span class="postfix required" title="REQUIRED">&#x2605;</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>shape.poly</a>|>shape</a>=<span class="attr-values">"poly"</span><span class="postfix required" title="REQUIRED">&#x2605;</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>shape.default</a>|>shape</a>=<span class="attr-values">"default"</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>coords.rect<|>coords<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>coords.circle<|>coords<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>coords.poly<|>coords<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>step.float</a>|>step</a> <span class="postfix optional" title="OPTIONAL">?</span><span class="attr-qualifier">(float)</span> |g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>step.integer</a>|>step</a> <span class="postfix optional" title="OPTIONAL">?</span><span class="attr-qualifier">(integer)</span> |g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>value.multiple</a>|>value</a> <span class="postfix optional" title="OPTIONAL">?</span><span class="attr-qualifier">(multiple addresses)</span> |g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>value.single</a>|>value</a> <span class="postfix optional" title="OPTIONAL">?</span><span class="attr-qualifier">(single address)</span> |g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>http-equiv.refresh</a>|>http-equiv</a>=<span class="attr-values">"refresh"</span><span class="postfix required" title="REQUIRED">&#x2605;</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>http-equiv.default-style</a>|>http-equiv</a>=<span class="attr-values">"default-style"</span><span class="postfix required" title="REQUIRED">&#x2605;</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>http-equiv.content-language</a>|>http-equiv</a>=<span class="attr-values">"content-language"</span><span class="postfix required" title="REQUIRED">&#x2605;</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>http-equiv.content-type</a>|>http-equiv</a>=<span class="attr-values">"content-type"</span><span class="postfix required" title="REQUIRED">&#x2605;</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>content.refresh<|>content<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>content.default-style<|>content<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>content.content-language<|>content<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>content.content-type<|>content<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>meta.name<|>meta name<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>meta.charset<|>meta charset<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>meta.http-equiv.refresh<|>meta http-equiv=refresh<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>meta.http-equiv.default-style<|>meta http-equiv=default-style<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>meta.http-equiv.content-language<|>meta http-equiv=content-language<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>meta.http-equiv.content-type<|>meta http-equiv=content-type<|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>wrap.hard</a>|>wrap</a>=<span class="attr-values">"hard"</span><span class="postfix required" title="REQUIRED">&#x2605;</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|>wrap.soft</a>|>wrap</a>=<span class="attr-values">"soft"</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|element\s+“([^”]+)”|element <span class="element">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|Element\s+“([^”]+)”|Element <span class="element">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|“([^”]+)”\s+element|<span class="element">$$1</span> element|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|“([^”]+)”\s+elements|<span class="element">$$1</span> elements|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|attribute\s+“([^”]+)”|attribute <span class="attribute">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|Attribute\s+“([^”]+)”|Attribute <span class="attribute">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|“([^”]+)”\s+attribute|<span class="attribute">$$1</span> attribute|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|element\s+&#8220;([^&]+)&#8221;|element <span class="element">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|Element\s+&#8220;([^&]+)&#8221;|Element <span class="element">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|&#8220;([^&]+)&#8221;\s+element|<span class="element">$$1</span> element|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|&#8220;([^&]+)&#8221;\s+elements|<span class="element">$$1</span> elements|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|attribute\s+&#8220;([^&]+)&#8221;|attribute <span class="attribute">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|Attribute\s+&#8220;([^&]+)&#8221;|Attribute <span class="attribute">$$1</span>|g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s|&#8220;([^&]+)&#8221;\s+attribute|<span class="attribute">$$1</span> attribute|g' \
	  > $@

html5:
	if [ -d /opt/workspace/github-html/heartbeat ]; then \
	  mkdir html5 && cp -pR /opt/workspace/github-html/heartbeat/ html5; \
	else \
	  CVSROOT=:pserver:anonymous@dev.w3.org:/sources/public $(CVS) $(CVSFLAGS) co html5/spec \
	  && rm -rf html5/CVS/ \
	  && rm -rf html5/spec/CVS/; \
	fi

html5-spec: html5
	mkdir $@
	for file in $(MULTIPAGE_SPEC_FILES); \
	  do $(PARSE) $(PARSEFLAGS) $</$$file > $@/$(notdir $$file); \
	done

Overview.html: html.spec.src.html src/status.html tools/specgen.xsl tools/toc.xsl tools/chunker.xsl
	$(XSLTPROC) $(XSLTPROCFLAGS) \
	  --param chunk 1 \
	  --param quiet 0 \
	  --stringparam TOC-file "Overview.html" \
	  --stringparam site "$(PUBSITE)" \
	  tools/specgen.xsl html.spec.src.html 2>MANIFEST.tmp > $@.tmp
	  $(TOHTML) $@.tmp 2>/dev/null \
	  | $(PERL) $(PERLFLAGS) -pi -e 's| xmlns="http://www.w3.org/1999/xhtml"||' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">|<meta charset=utf-8>|' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|<!DOCTYPE html PUBLIC "html" "about:legacy-compat">|<!doctype html>|' \
	  > $@

index.html: Overview.html
	cp $< $@

MANIFEST: MANIFEST.tmp
ifneq ($(shell if [ -f MANIFEST.tmp ]; then $(GREP) $(GREPFLAGS) -v html MANIFEST.tmp; fi),)
  $(error Error: MANIFEST.tmp corrupted: "$(shell if [ -f MANIFEST.tmp ]; then $(HEAD) $(HEADFLAGS) -n1 MANIFEST.tmp; fi)")
endif
	@if [ -n "$(GREP) $(GREPFLAGS) UNDEFINED $<" ]; then \
	  $(GREP) $(GREPFLAGS) UNDEFINED $<; \
	fi; \
	for file in $(shell $(GREP) $(GREPFLAGS) -v "UNDEFINED" $< | $(GREP) $(GREPFLAGS) -v "\.xhtml"); \
	  do $(TOHTML) - 2>/dev/null < $$file \
	  | $(PERL) $(PERLFLAGS) -pi -e 's| xmlns="http://www.w3.org/1999/xhtml"||' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">|<meta charset=utf-8>|' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|<!DOCTYPE html PUBLIC "html" "about:legacy-compat">|<!doctype html>|' \
	  > $$file.tmp; \
	  mv $$file.tmp $$file; \
	done
	@$(GREP) $(GREPFLAGS) -v "UNDEFINED" $< > $@
	$(PERL) $(PERLFLAGS) -pi -e 's|<a href=".html#html-elements">|<a href="elements.html#html-elements">|' index-of-terms.html

spec.html: html.spec.src.html src/status.html tools/specgen.xsl tools/toc.xsl
	$(XSLTPROC) $(XSLTPROCFLAGS) \
	  --stringparam TOC-file "spec.html" \
	  --stringparam site "$(PUBSITE)" \
	  tools/specgen.xsl html.spec.src.html \
	  | $(TOHTML) - 2>/dev/null \
	  | $(PERL) $(PERLFLAGS) -pi -e 's| xmlns="http://www.w3.org/1999/xhtml"||' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">|<meta charset=utf-8>|' \
	  | $(PERL) $(PERLFLAGS) -pi -e 's|<!DOCTYPE html PUBLIC "html" "about:legacy-compat">|<!doctype html>|' \
	  > $@

aria: aria/Overview.html aria/spec.html

aria/html.rng: syntax
	$(TRANG) $(TRANGFLAGS) aria/html.rnc $@

aria/html-compiled.rng: aria/html.rng
	INCELIM=$(realpath $(INCELIM_DIR)) sh $(INCELIM_DIR)/$(INCELIM) $(INCELIMFLAGS) $<

aria/html-compiled.rng.combined: aria/html-compiled.rng tools/combine.xsl tools/strip-comments.xsl
	$(XSLTPROC) $(XSLTPROCFLAGS) tools/combine.xsl $< \
	  | $(XSLTPROC) $(XSLTPROCFLAGS) tools/strip-comments.xsl - > $@

aria/schema.html: aria/html-compiled.rng.combined
	$(JAVA) $(JAVAFLAGS) -jar tools/trang.jar -I rng -O rnc $< $@
	$(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s/\s+<a[^<]+<\/a> notAllowed//g' $@

aria/html.spec.src.html: aria/html-compiled.rng aria/schema.html \
  tools/generate-spec-source.xsl syntax/relaxng/assertions.sch \
  src/head.html src/header.src.html src/intro-scope.html \
  src/terms.html src/syntax.html src/documents.html \
  $(ELEMENTS) src/attributes.html src/datatypes.html src/references.html \
  LICENSE.xml html.css.xml html.css.LICENSE.xml
	$(XSLTPROC) $(XSLTPROCFLAGS) \
	  --param aria 1 \
	  --param rnc-html "document('../aria/schema.html')" \
	  --param head "document('../aria/head.src.html')" \
	  --param header "document('../aria/header.src.html')" \
	  tools/generate-spec-source.xsl $< > $@

aria/Overview.html: aria/html.spec.src.html src/status.html tools/specgen.xsl tools/toc.xsl tools/chunker.xsl
	$(XSLTPROC) $(XSLTPROCFLAGS) \
	  --param aria 1 --param chunk 1 --stringparam TOC-file "Overview.html" --param quiet 1 \
	  tools/specgen.xsl $< \
	  | $(TOHTML) - 2>/dev/null \
	  > $@

aria/spec.html: aria/html.spec.src.html src/status.html tools/specgen.xsl tools/toc.xsl
	$(XSLTPROC) $(XSLTPROCFLAGS) \
	  --stringparam TOC-file "spec.html" \
	  tools/specgen.xsl $< \
	  | $(TOHTML) - 2>/dev/null \
	  > $@

aria/style.css: style.css
	cp $< $@

aria/W3C-ED.css: W3C-ED.css
	cp $< $@

aria/logo-ED.png: logo-ED.png
	cp $< $@

upload:
	$(SCP) $(SCPFLAGS) *.html *.css help.whatwg.org:~/help.whatwg.org/html/markup

webapps.html:
	$(CURL) $(CURLFLAGS) http://dev.w3.org/html5/spec/Overview.html \
	  | $(PARSE) $(PARSEFLAGS) - > $@

elements-generated.html: webapps.html tools/get-elements.xsl
	$(XSLTPROC) $(XSLTPROCFLAGS) tools/get-elements.xsl $< \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s/\s+<\/p>/<\/p>/g' \
	  | $(PERL) $(PERLFLAGS) -pi -e 'undef $$/; s/ xmlns=""//g' \
	  > $@

README.markdown: README.html
	$(HTML2MARKDOWN) $(HTML2MARKDOWNFLAGS) $< > $@

syntax:
ifneq ($(WHATTF_SCHEMA),)
	cp -pR $(WHATTF_SCHEMA) syntax
	$(RM) -f syntax/datatype
	-$(PATCH) $(PATCHFLAGS) -p1 -d syntax < patch-schema
endif

clean:
	$(RM) html.rng
	$(RM) LICENSE.xml
	$(RM) html.css.LICENSE.xml
	$(RM) html.css.xml
	$(RM) html.spec.src.html
	$(RM) Overview.html.tmp
	$(RM) MANIFEST.tmp
	$(RM) MANIFEST
	$(RM) -r html5
	$(RM) -r html5-spec
ifneq ($(OTHER_RNG),)
	$(RM) $(OTHER_RNG)
endif
	$(RM) html-compiled.rng
	$(RM) html-compiled.rng.combined
	$(RM) aria/html.rng
	$(RM) aria/html.spec.src.html
ifneq ($(ARIA_OTHER_RNG),)
	$(RM) $(ARIA_OTHER_RNG)
endif
	$(RM) aria/html-compiled.rng
	$(RM) aria/html-compiled.rng.combined
	@echo
	@echo "NOTE: You can run \"make distclean && make\" to re-download third-party dependencies and rebuild from scratch."
	@echo

schemaclean:
	$(RM) -r syntax

distclean: clean schemaclean syntax
	$(RM) webapps.html
	$(RM) html.css
	$(RM) fragment-links.js
	$(RM) fragment-links.html
	$(RM) fragment-links-full.js
	$(RM) fragment-links-full.html
