<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dotify="http://code.google.com/p/dotify/"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all">
	
	<xsl:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/transform/block-translator-template.xsl"/>
	
	<xsl:param name="query" required="yes"/>
	
	<xsl:template match="css:block" mode="#default before after">
		<xsl:apply-templates select="node()[1]" mode="treewalk">
			<xsl:with-param name="new-text-nodes" select="for $text in //text() return dotify:translate($query,$text)"/>
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>
