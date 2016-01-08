<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output doctype-public="-//NISO//DTD dtbook 2005-3//EN" doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd"/>

	<!-- paragraph type for linegroups -->
	<xsl:param name="paragraph-type" select="''"/> <!-- precedingemptyline, indented, precedingseparator, no-indent -->
	<!-- remove @class on p elements -->
	<xsl:param name="clear-p-class" select="false()" as="xs:boolean"/>

    <xsl:template match="dtb:linegroup">
      <xsl:element name="p" namespace="http://www.daisy.org/z3986/2005/dtbook/">
          <xsl:if test="preceding-sibling::dtb:linegroup">
          	<xsl:if test="$paragraph-type!=''">
	            <xsl:attribute name="class">
	                <xsl:value-of select="$paragraph-type"/>
	            </xsl:attribute>
          	</xsl:if>
          </xsl:if>
          <xsl:apply-templates/>
      </xsl:element>
    </xsl:template>

    <xsl:template match="text()[normalize-space()='' and parent::dtb:linegroup]"></xsl:template>

    <xsl:template match="dtb:line">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::dtb:line">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
	
	<xsl:template match="dtb:p[@class and $clear-p-class]">
		<xsl:copy>
			<xsl:copy-of select="@*[local-name()!='class']"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

    <xsl:template match="*|comment()|processing-instruction()">
        <xsl:call-template name="copy"/>
    </xsl:template>

    <xsl:template name="copy">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>