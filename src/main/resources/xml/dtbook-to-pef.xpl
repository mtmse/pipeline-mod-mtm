<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="mtm:dtbook-to-pef" version="1.0"
                xmlns:mtm="http://www.mtm.se/pipeline/"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:dotify="http://code.google.com/p/dotify/"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">DTBook to PEF (MTM)</h1>
        <p px:role="desc">Transforms a DTBook (DAISY 3 XML) document into a PEF.</p>
    </p:documentation>
    
    <p:input port="source" primary="true" px:name="source" px:media-type="application/x-dtbook+xml"/>
    
    <p:option name="include-preview" required="false" px:type="boolean" select="''"/>
    <p:option name="include-brf" required="false" px:type="boolean" select="''"/>
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI"/>
    <p:option name="identifier" required="true" px:type="string"/>
    <p:option name="rows" required="false" px:type="string" select="29">
        <p:documentation>Number of rows</p:documentation>
    </p:option>
    <p:option name="cols" required="false" px:type="string" select="28">
        <p:documentation>Number of characters on a row that can contain text.</p:documentation>
    </p:option>
    <p:option name="rowgap" required="false" px:type="string" select="0">
        <p:documentation>Row spacing as defined in the PEF-format.</p:documentation>
    </p:option>
    <p:option name="inner-margin" required="false" px:type="string" select="2">
        <p:documentation>The inner margin.</p:documentation>
    </p:option>
    <p:option name="outer-margin" required="false" px:type="string" select="2">
        <p:documentation>The outer margin.</p:documentation>
    </p:option>
    <p:option name="splitterMax" required="false" px:type="string" select="50">
        <p:documentation>The maximum number of sheets in a volume.</p:documentation>
    </p:option>
    <p:option name="keepCaptions" required="false" px:type="boolean" select="true()">
        <p:documentation>Keeps imggroup if value is true or if imagegroup contains a prodnote</p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/braille/dotify-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>

    <p:xslt>
		<p:input port="stylesheet">
			<p:document href="move-cover-text.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>

    <p:xslt>
		<p:input port="stylesheet">
			<p:document href="punktinfo.xsl"/>
		</p:input>
        <!-- format-date(current-date(), '[Y0001]') -->
        <p:with-param name="year" select="'2015'"/>
        <p:with-param name="identifier" select="$identifier"/>
        <p:with-param name="captions" select="if ($keepCaptions) then ('keep') else ('remove')"></p:with-param>
		<p:input port="parameters">
		      <p:empty/>
		</p:input>
	</p:xslt>
    
    <dotify:xml-to-obfl locale="sv-SE">
        <!-- <p:with-option name="identifier" select="$identifier"/> -->
        <p:with-option name="rows" select="$rows"/>
        <p:with-option name="cols" select="$cols"/>
        <p:with-option name="rowgap" select="$rowgap"/>
        <p:with-option name="inner-margin" select="$inner-margin"/>
        <p:with-option name="outer-margin" select="$outer-margin"/>
        <p:with-option name="splitterMax" select="$splitterMax"/>
        
        <!-- <p:with-option name="format" select="'pef'"/> -->
        <!-- dotify-options="(rows:29)(cols:28)(rowgap:0)" -->
    </dotify:xml-to-obfl>
    
    <dotify:obfl-to-pef locale="sv-SE" mode="uncontracted"/>

    <p:xslt>
		<p:input port="stylesheet">
			<p:document href="pef-meta-finalizer.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="pef-section-patch.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>

    <pef:store>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="name" select="replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1')">
            <p:pipe step="main" port="source"/>
        </p:with-option>
        <p:with-option name="include-preview" select="$include-preview"/>
        <p:with-option name="include-brf" select="$include-brf"/>
    </pef:store>
    
</p:declare-step>
