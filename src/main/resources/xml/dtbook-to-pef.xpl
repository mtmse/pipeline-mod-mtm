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
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/dotify-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    
    <dotify:xml-to-obfl locale="sv-SE" dotify-options="(rows:29)(cols:28)(rowgap:4)"/>
    
    <dotify:obfl-to-pef locale="sv-SE" mode="uncontracted"/>
    
    <pef:store>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="name" select="replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1')">
            <p:pipe step="main" port="source"/>
        </p:with-option>
        <p:with-option name="include-preview" select="$include-preview"/>
        <p:with-option name="include-brf" select="$include-brf"/>
    </pef:store>
    
</p:declare-step>
