<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="mtm:file-to-pef" version="1.0"
                xmlns:mtm="http://www.mtm.se/pipeline/"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:dotify="http://code.google.com/p/dotify/"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                exclude-inline-prefixes="#all">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook/EPUB to PEF (MTM)</h1>
        <p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into a PEF.</p>
    </p:documentation>
    
    <p:output port="validation-status" px:media-type="application/vnd.pipeline.status+xml">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h1 px:role="name">Validation status</h1>
            <p px:role="desc">Validation status (http://code.google.com/p/daisy-pipeline/wiki/ValidationStatusXML).</p>
        </p:documentation>
        <p:pipe port="validation-status" step="validate-pef"/>
    </p:output>
    
    <!-- ============ -->
    <!-- Main options -->
    <!-- ============ -->
    <p:option name="source" required="true" px:type="anyFileURI" px:sequence="false"
              px:media-type="application/x-dtbook+xml application/epub+zip">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Input DTBook or EPUB</h2>
        </p:documentation>
    </p:option>
    <!--
    <p:option name="ascii-table" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">ASCII braille table</h2>
            <p px:role="desc">The ASCII braille table, used for example to render BRF files. **Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <p:option name="include-preview" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Include preview HTML</h2>
            <p px:role="desc">Includes a preview HTML.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-brf" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Include .brf</h2>
            <p px:role="desc">Includes a brf-file.</p>
        </p:documentation>
    </p:option>
    <p:option name="include-obfl" required="false" px:type="boolean" select="'false'">
        <p:documentation>
            <h2 px:role="name">Include OBFL</h2>
            <p px:role="desc">Keeps the intermediary OBFL-file for debugging.</p>
        </p:documentation>
    </p:option>
    <!--
        TODO: also add to other scripts?
    -->
    <p:option name="identifier" px:type="string" required="true">
        <p:pipeinfo>
            <px:data-type>
                <data type="string">
                    <param name="pattern">P[0-9]{5}</param>
                </data>
            </px:data-type>
        </p:pipeinfo>
        <p:documentation>
            <h2 px:role="name">Identifier</h2>
            <p px:role="desc">The identifier for the resulting PEF-file.

Must be the letter "P" and 5 digits.</p>
        </p:documentation>
    </p:option>
    
    <!-- =========== -->
    <!-- Page layout -->
    <!-- =========== -->
    <!--
        TODO: make name/description/behavior match with other scripts? currently behavior is that
        actual width of PEF is page-width + inner-margin + outer-margin, while in other scripts
        actual width is determined by page-width only
    -->
    <p:option name="page-width" required="false" px:type="integer" select="'28'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Columns</h2>
            <p px:role="desc">Number of characters on a row.</p>
        </p:documentation>
    </p:option>
    <!--
        TODO: make name/description/behavior match with other scripts?
    -->
    <p:option name="page-height" required="false" px:type="integer" select="'29'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Rows</h2>
            <p px:role="desc">Number of rows.</p>
        </p:documentation>
    </p:option>
    <!--
    <p:option name="left-margin" required="false" px:type="integer" select="'0'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Left margin</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <!--
        TODO: also add to other scripts?
    -->
    <p:option name="inner-margin" required="false" px:type="integer" select="'2'">
        <p:documentation>
            <h2 px:role="name">Page layout: Inner margin</h2>
            <p px:role="desc">The inner margin size, counted in characters.</p>
        </p:documentation>
    </p:option>
    <!--
        TODO: also add to other scripts?
    -->
    <p:option name="outer-margin" required="false" px:type="integer" select="'2'">
        <p:documentation>
            <h2 px:role="name">Page layout: Outer margin</h2>
            <p px:role="desc">The outer margin size, counted in characters.</p>
        </p:documentation>
    </p:option>
    <p:option name="duplex" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page layout: Duplex</h2>
            <p px:role="desc">When enabled, will print on both sides of the paper.</p>
        </p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Headers/footers -->
    <!-- =============== -->
    <!--
    <p:option name="levels-in-footer" required="false" px:type="integer" select="'6'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Headers/footers: Levels in footer</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    
    <!-- ============================== -->
    <!-- Translation/formatting of text -->
    <!-- ============================== -->
    <!--
    <p:option name="main-document-language" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Main document language</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <p:option name="hyphenation" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Hyphenation</h2>
            <p px:role="desc">When enabled, will automatically hyphenate text.</p>
        </p:documentation>
    </p:option>
    <p:option name="line-spacing" required="false" select="'single'">
        <p:pipeinfo>
            <px:data-type>
                <choice>
                    <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0" xml:lang="en">
                        <value>Single</value>
                        <value>Double</value>
                    </documentation>
                    <value>single</value>
                    <value>double</value>
                </choice>
            </px:data-type>
        </p:pipeinfo>
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Line spacing</h2>
            <p px:role="desc">'single' or 'double' line spacing.</p>
        </p:documentation>
    </p:option>
    <!--
    <p:option name="tab-width" required="false" px:type="integer" select="'4'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Tab width</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <p:option name="capital-letters" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Translation/formatting of text: Capital letters</h2>
            <p px:role="desc">When enabled, will indicate capital letters.</p>
        </p:documentation>
    </p:option>
    
    <!-- ============== -->
    <!-- Block elements -->
    <!-- ============== -->
    <!--
        TODO: make name/description/behavior match with other scripts?
    -->
    <p:option name="include-captions" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include image captions</h2>
            <p px:role="desc">When enabled, will include captions for images.

When disabled, images will only be rendered if they have a prodnote.</p>
        </p:documentation>
    </p:option>
    <!--
    <p:option name="include-images" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include images</h2>
            <p px:role="desc">When enabled, will include the alt text of the images. When disabled, the images will be completely removed. **Not implemented**</p>
        </p:documentation>
    </p:option>
    <p:option name="include-image-groups" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Include image groups</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <p:option name="merge-line-groups" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Block elements: Merge line groups</h2>
            <p px:role="desc">When enabled, lines in a linegroup are merged into a single paragraph, unless the line starts with a dash. 
		Note that this option only works when mtm-addons are applied (see advanced options) and only for DTBook.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="paragraph-layout-style" required="false" select="'indent'">
        <p:pipeinfo>
            <px:data-type>
                <choice>
                    <value>indent</value>
                    <value>empty-line</value>
                </choice>
            </px:data-type>
        </p:pipeinfo>
    	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
    		<h2 px:role="name">Block elements: Paragraph layout style</h2>
    		<p px:role="desc">Sets the default paragraph layout style to the specified value. Note that paragraphs with an explicit paragraph style are not effected.</p>
    	</p:documentation>
    </p:option>
    
    <!-- =============== -->
    <!-- Inline elements -->
    <!-- =============== -->
    <p:option name="text-level-formatting" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Text-level formatting (emphasis, strong)</h2>
            <p px:role="desc">When enabled, text that is in bold or italics in the print version will be rendered in bold or italics in the braille version as well.</p>
        </p:documentation>
    </p:option>
    <!--
    <p:option name="include-note-references" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Include note references</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <!--
    <p:option name="include-producers-notes" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Inline elements: Include producer's notes</h2>
            <p px:role="desc">When enabled, producer's notes are included in the content. **Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    
    <!-- ============ -->
    <!-- Page numbers -->
    <!-- ============ -->
    <p:option name="show-braille-page-numbers" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Show braille page numbers</h2>
        </p:documentation>
    </p:option>
    <p:option name="show-print-page-numbers" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Show print page numbers</h2>
            <p px:role="desc">When enabled, print page numbers are rendered in the upper right corner of left hand pages.</p>
        </p:documentation>
    </p:option>
    <p:option name="show-print-page-breaks" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Show print page breaks</h2>
            <p px:role="desc">When enabled, print page breaks are indicated with a '⠌⠌' mark at the exact location of the page break and a '⠿' mark in the left margin of the row that includes the break.</p>
        </p:documentation>
    </p:option>
    
    <!--
    <p:option name="force-braille-page-break" required="false" px:type="boolean" select="'false'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Page numbers: Force braille page break</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    
    <!-- ================= -->
    <!-- Table of contents -->
    <!-- ================= -->
    <p:option name="toc-depth" required="false" px:type="integer" select="'6'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Table of contents: Table of contents depth</h2>
            <p px:role="desc">The depth of the table of contents hierarchy to include. '0' means no table of contents.</p>
        </p:documentation>
    </p:option>
    <!--
        TODO: also add to other scripts?
    -->
    <p:option name="volume-toc" required="false" px:type="boolean" select="'true'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Table of contents: Volume level table of contents</h2>
            <p px:role="desc">Include a volume range table of contents at the beginning of every volume (except the first which always has a full table of contents).</p>
        </p:documentation>
    </p:option>
    
    <!-- ==================== -->
    <!-- Placement of content -->
    <!-- ==================== -->
    <!--
    <p:option name="footnotes-placement" required="false" px:type="string" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Footnotes placement</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <p:option name="colophon-metadata-placement" required="false" select="'end'">
        <p:pipeinfo>
            <px:data-type>
                <choice>
                    <value>begin</value>
                    <value>end</value>
                </choice>
            </px:data-type>
        </p:pipeinfo>
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Colophon/metadata placement</h2>
        </p:documentation>
    </p:option>
    <p:option name="rear-cover-placement" required="false" select="'end'">
        <p:pipeinfo>
            <px:data-type>
                <choice>
                    <value>begin</value>
                    <value>end</value>
                </choice>
            </px:data-type>
        </p:pipeinfo>
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Placement of content: Rear cover placement</h2>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Volumes -->
    <!-- ======= -->
    <!--
    <p:option name="number-of-pages" required="false" px:type="integer" select="'50'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Number of pages</h2>
            <p px:role="desc">**Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    <p:option name="maximum-number-of-pages" required="false" px:type="integer" select="'50'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Maximum number of pages</h2>
            <p px:role="desc">The maximum number of sheets in a volume.</p>
        </p:documentation>
    </p:option>
    <!--
    <p:option name="minimum-number-of-pages" required="false" px:type="integer" select="'30'">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Volumes: Minimum number of pages</h2>
            <p px:role="desc">The minimum number of sheets in a volume. **Not implemented**</p>
        </p:documentation>
    </p:option>
    -->
    
    <!-- ===== -->
    <!-- Other -->
    <!-- ===== -->
    <!--
        TODO: also add to other scripts?
    -->
    
    <p:option name="apply-mtm-addons" required="false" px:type="boolean" select="'true'">
        <p:documentation>
            <h2 px:role="name">Other: Apply mtm addons</h2>
            <p px:role="desc">Apply mtm addons.</p>
        </p:documentation>
    </p:option>

    <p:option name="other" required="false" px:type="string" select="''">
        <p:documentation>
            <h2 px:role="name">Other: Advanced options</h2>
            <p px:role="desc">Additional options using the following syntax: (name1:value1)(name2:value2)...</p>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Outputs -->
    <!-- ======= -->
    <p:option name="pef-output-dir" required="true" px:output="result" px:type="anyDirURI">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">PEF</h2>
            <h2 px:role="desc">Output directory for the PEF</h2>
        </p:documentation>
    </p:option>
    <p:option name="brf-output-dir" required="false" px:output="result" px:type="anyDirURI" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">BRF</h2>
            <h2 px:role="desc">Output directory for the BRF</h2>
        </p:documentation>
    </p:option>
    <p:option name="preview-output-dir" required="false" px:output="result" px:type="anyDirURI" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Preview</h2>
            <h2 px:role="desc">Output directory for the HTML preview</h2>
        </p:documentation>
    </p:option>
    <p:option name="temp-dir" required="false" px:output="temp" px:type="anyDirURI" select="''">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Temporary directory</h2>
            <p px:role="desc" xml:space="preserve">Directory for storing temporary files during conversion.</p>
        </p:documentation>
    </p:option>
    
    <!-- ======= -->
    <!-- Imports -->
    <!-- ======= -->
    <p:import href="http://www.daisy.org/pipeline/modules/braille/dotify-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    
    <!-- =============== -->
    <!-- Create temp dir -->
    <!-- =============== -->
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $pef-output-dir"/>
    </px:tempdir>
    <p:sink/>
    
    <!-- =================== -->
    <!-- Convert with Dotify -->
    <!-- =================== -->
    
    <dotify:file-to-obfl locale="sv-SE" name="obfl">
        <p:with-option name="source" select="$source"/>
        <p:with-option name="rows" select="$page-height"/>
        <p:with-option name="cols" select="$page-width"/>
        <!-- single line spacing is a better choice for unexpected input -->
        <p:with-option name="rowgap" select="if ($line-spacing='double') then 4 else 0"/>
        <p:with-option name="inner-margin" select="$inner-margin"/>
        <p:with-option name="outer-margin" select="$outer-margin"/>
        <p:with-option name="splitterMax" select="$maximum-number-of-pages"/>
        <p:with-option name="dotify-options" select="$other"/>
        <p:with-param port="parameters" name="identifier" select="$identifier"/>
        <p:with-param port="parameters" name="duplex" select="$duplex"/>
        <p:with-param port="parameters" name="hyphenate" select="$hyphenation"/>
        <p:with-param port="parameters" name="toc-depth" select="$toc-depth"/>
        <p:with-param port="parameters" name="volume-toc" select="$volume-toc"/>
        <p:with-param port="parameters" name="show-braille-page-numbers" select="$show-braille-page-numbers"/>
        <p:with-param port="parameters" name="show-print-page-numbers" select="$show-print-page-numbers"/>
        <p:with-param port="parameters" name="show-print-page-breaks" select="$show-print-page-breaks"/>
        <p:with-param port="parameters" name="colophon-metadata-placement" select="$colophon-metadata-placement"/>
        <p:with-param port="parameters" name="rear-cover-placement" select="$rear-cover-placement"/>
        <p:with-param port="parameters" name="default-paragraph-separator" select="$paragraph-layout-style"/>
	<p:with-param port="parameters" name="merge-line-groups" select="$merge-line-groups"/>
        <p:with-param port="parameters" name="apply-mtm-addons" select="$apply-mtm-addons"/>
        <!-- Disables the toc preamble, requires dotify.task.impl:2.11.1+ -->
        <p:with-param port="parameters" name="l10nTocDescription" select="''"/>
        <!-- <p:with-option name="format" select="'pef'"/> -->
    </dotify:file-to-obfl>
    
    <dotify:obfl-to-pef locale="sv-SE" mode="uncontracted">
        <p:with-option name="identifier" select="$identifier"/>
        <p:with-param port="parameters" name="mark-capital-letters" select="$capital-letters"/>
        <p:with-param port="parameters" name="remove-styles" select="$text-level-formatting='false'"/>
    </dotify:obfl-to-pef>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="http://www.mtm.se/pipeline/modules/braille/internal/pef-meta-finalizer.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="http://www.mtm.se/pipeline/modules/braille/internal/pef-section-patch.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <pef:validate name="validate-pef">
    	<p:with-option name="assert-valid" select="'false'"/>
    	<p:with-option name="temp-dir" select="$temp-dir"/>
    </pef:validate>
    
    <!-- ===== -->
    <!-- Store -->
    <!-- ===== -->
    
    <pef:store>
        <p:with-option name="href" select="concat($pef-output-dir,'/',$identifier,'/',$identifier,'.pef')"/>
        <p:with-option name="preview-href" select="if ($include-preview='true' and $preview-output-dir!='')
                                                   then concat($preview-output-dir,'/',$identifier,'.pef.html')
                                                   else ''"/>
        <p:with-option name="brf-dir-href" select="if ($include-brf='true') then $brf-output-dir else ''"/>
        <p:with-option name="brf-name-pattern" select="concat($identifier,'_vol-{}')"/>
        <p:with-option name="brf-single-volume-name" select="$identifier"/>
    </pef:store>
    
    <p:choose>
        <p:when test="$include-obfl='true'">
            <p:store>
                <p:input port="source">
                    <p:pipe step="obfl" port="result"/>
                </p:input>
                <p:with-option name="href" select="concat($pef-output-dir,'/',$identifier,'/',$identifier,'.obfl')"/>
            </p:store>
        </p:when>
        <p:otherwise>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
         </p:otherwise>
    </p:choose>
    
</p:declare-step>
