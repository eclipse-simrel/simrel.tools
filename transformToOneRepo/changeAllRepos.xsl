<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- 
       naming the factory and passing in on -Djavax.xml.transform.TransformerFactory
       avoid some spurious error messages about "UTF-8 not supported by java".
       Though we use ASCII, to match what is already in b3aggrcon files.
       Though does require it to be on classpath, then.
   -->
  <factory name="com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl">
  </factory>
  <xsl:output
    indent="yes"
    encoding="ASCII"
    omit-xml-declaration="no"
    method="xml" />

  <xsl:param name="newRepository">
    $newRepository
  </xsl:param>

<!--  work around for bug with no EOL after XML Decl -->
  <xsl:template match="/">
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates />
  </xsl:template>

    <!-- standard "copy all" template -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@location[parent::repositories]">
    <xsl:attribute name="location"><xsl:value-of select="$newRepository" /></xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
