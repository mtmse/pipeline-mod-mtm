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
    
    <!-- 
    <p:option name="include-preview" required="false" px:type="boolean" select="''">
    	<p:documentation>
			<h2 px:role="name">Include preview HTML</h2>
			<p px:role="desc">Includes a preview HTML</p>
		</p:documentation>
    </p:option>
    <p:option name="include-brf" required="false" px:type="boolean" select="''">
    	<p:documentation>
			<h2 px:role="name">Include .brf</h2>
			<p px:role="desc">Includes a brf-file.</p>
		</p:documentation>
    </p:option> -->
    <p:option name="output-dir" required="true" px:output="result" px:type="anyDirURI"/>
    <p:option name="identifier" required="true" px:type="string">
    	<p:documentation>
			<h2 px:role="name">Identifier</h2>
			<p px:role="desc">The identifier for the resulting PEF-file.</p>
		</p:documentation>
    </p:option>
    <!--
		<p:documentation>
			<h2 px:role="name"></h2>
			<p px:role="desc"></p>
		</p:documentation>
	-->
	<p:option name="keepCaptions" required="false" px:type="boolean" select="'true'">
        <p:documentation>
			<h2 px:role="name">Keep imggroup without prodnote</h2>
        	<p px:role="desc">Keeps imggroup if value is true or if imagegroup contains a prodnote.</p>
        </p:documentation>
    </p:option>
	<p:option name="single-line-spacing" required="false" px:type="boolean" select="'true'">
        <p:documentation>
            <h2 px:role="name">Single line spacing</h2>
        	<p px:role="desc">Select 'No' for double line spacing.</p>
		</p:documentation>
    </p:option>
    <p:option name="rows" required="false" px:type="string" select="29">
        <p:documentation>
        	<h2 px:role="name">Rows</h2>
        	<p px:role="desc">Number of rows.</p>
        </p:documentation>
    </p:option>
    <p:option name="cols" required="false" px:type="string" select="28">
        <p:documentation>
        	<h2 px:role="name">Columns</h2>
        	<p px:role="desc">Number of characters on a row.</p>
        </p:documentation>
    </p:option>
    <p:option name="inner-margin" required="false" px:type="string" select="2">
        <p:documentation>
            <h2 px:role="name">Inner margin</h2>
        	<p px:role="desc">The inner margin size, counted in characters.</p>
        </p:documentation>
    </p:option>
    <p:option name="outer-margin" required="false" px:type="string" select="2">
        <p:documentation>
			<h2 px:role="name">Outer margin</h2>
			<p px:role="desc">The outer margin size, counted in characters.</p>
        </p:documentation>
    </p:option>
    <!-- 
    <p:option name="splitterMax" required="false" px:type="string" select="50">
        <p:documentation>
			<h2 px:role="name">Splitter max</h2>
			<p px:role="desc">The maximum number of sheets in a volume.</p>
        </p:documentation>
    </p:option>  -->
    <p:option name="include-obfl" required="false" px:type="boolean" select="'false'">
		<p:documentation>
			<h2 px:role="name">Include OBFL</h2>
			<p px:role="desc">Keeps the intermediary OBFL-file for debugging.</p>
		</p:documentation>
    </p:option>
    <p:option name="query" required="false" px:type="string" select="''">
    	<p:documentation>
    	    <h2 px:role="name">Advanced options</h2>
        	<p px:role="desc">Additional options using the following syntax: (name1:value1)(name2:value2)...</p>
    	</p:documentation>
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
        <p:with-param name="identifier" select="$identifier"/>
        <!-- Negative form is used, because keep is a better choice for unexpected input -->
        <p:with-param name="captions" select="if ($keepCaptions='false') then ('remove') else ('keep')"></p:with-param>
		<p:input port="parameters">
		      <p:empty/>
		</p:input>
	</p:xslt>
    
    <dotify:xml-to-obfl locale="sv-SE" name="obfl">
        <!-- <p:with-option name="identifier" select="$identifier"/> -->
        <p:with-option name="rows" select="if ($rows='') then (29) else ($rows)"/>
        <p:with-option name="cols" select="if ($cols='') then (28) else ($cols)"/>
        <!-- Negative form is used, because single line spacing is a better choice for unexpected input -->
        <p:with-option name="rowgap" select="if ($single-line-spacing='false') then (4) else (0)"/>
        <p:with-option name="inner-margin" select="if ($inner-margin='') then (2) else ($inner-margin)"/>
        <p:with-option name="outer-margin" select="if ($outer-margin='') then (2) else ($outer-margin)"/>
        <p:with-option name="splitterMax" select="50"/> <!--  if ($splitterMax='') then (50) else ($splitterMax)"/> -->
        <p:with-option name="dotify-options" select="$query"/>
        <!-- <p:with-option name="format" select="'pef'"/> -->
    </dotify:xml-to-obfl>

    <p:choose>
    	<p:when test="$include-obfl='true'">
		    <p:store>
				<p:input port="source">
					<p:pipe step="obfl" port="result"/>
				</p:input>
				<p:with-option name="href" select="concat($output-dir, $identifier, '.obfl')"/>
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

    <dotify:obfl-to-pef locale="sv-SE" mode="uncontracted">
    	<p:input port="source">
    		<p:pipe step="obfl" port="result"/> 
    	</p:input>
    </dotify:obfl-to-pef>

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
        <p:with-option name="name" select="if ($identifier='') then ('result') else ($identifier)"/>
        <p:with-option name="include-preview" select="'false'"/>
        <p:with-option name="include-brf" select="'false'"/>
    </pef:store>
    
</p:declare-step>
