<?xml version="1.0" encoding="UTF-8"?>

<!--
    Dryad stylesheet

    This stylesheet overrides and extends the basic dri2xhtml of Manakin.

    Authors: Amol Bapat, Ryan Scherle, Kevin Clarke
-->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:encoder="xalan://java.net.URLEncoder" xmlns:decoder="xalan://java.net.URLDecoder"
                exclude-result-prefixes="xalan encoder decoder" xmlns:exslt="http://exslt.org/dynamic"
                version="1.0">

    <xsl:import href="../dri2xhtml.xsl"/>

    <xsl:import href="DryadItemSummary.xsl"/>
    <xsl:import href="DryadFooter.xsl"/>
    <xsl:import href="DryadSearch.xsl"/>
    <xsl:import href="integrated-view.xsl"/>

    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>

    <!-- Check to see if XHTML pages are included via this XSLT -->
    <xsl:variable name="meta" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata"/>
    <xsl:variable name="pageName" select="$meta[@element='request'][@qualifier='URI']"/>
    <xsl:variable name="doc" select="document(concat('pages/', $pageName, '.xhtml'))"/>


    <!-- Overwriting the default DSpace dri:body template to check for pages -->
    <xsl:template match="dri:body">
        <div id="ds-body">
            <xsl:if test="$meta[@element='alert'][@qualifier='message']">
                <div id="ds-system-wide-alert">
                    <p>
                        <xsl:copy-of select="$meta[@element='alert'][@qualifier='message']/node()"/>
                    </p>
                </div>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$doc">
                    <xsl:copy-of select="$doc//div[@id='ds-body']/*"/>
                    <!-- hint 'error=' is used to indicate we should append -->
                    <xsl:if test="$meta[@qualifier='queryString'][starts-with(., 'error=')]">
                        <div style="margin-top: 20px;">
                            <xsl:variable name="report_text">
                                <xsl:call-template name="parse-query-param">
                                    <xsl:with-param name="param-name">body</xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <form action="/feedback" method="post" onsubmit="javascript:tSubmit(this);">
                                <input name="email" type="hidden" value="help@datadryad.org"/>
                                <textarea name="comments" onfocus="javascript:tFocus(this);" cols="60" rows="15">
                                    <xsl:value-of select="decoder:decode($report_text)"/>
                                </textarea>
                                <br/>
                                <input name="submit" type="submit" value="Send Feedback"/>
                            </form>
                        </div>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
 
    </xsl:template>


    <!-- Overwriting the default DSpace head element template to check for pages -->
    <xsl:template name="buildHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <meta name="google-site-verification" content="IqB7A6dUGs-0ncAgB3f0PXxeO_OcjyVAtRNdBFie4AM"/>
            <!-- Add stylsheets -->
            <xsl:for-each select="$meta[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$meta[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of select="$meta[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <link type="application/rss+xml" rel="alternate" href="/feed/rss_2.0/10255/3"/>
            <link type="application/rss+xml" rel="alternate" href="/feed/rss_2.0/10255/3"/>
            <link type="application/atom+xml" rel="alternate" href="/feed/atom_1.0/10255/3"/>
            <link rel="icon" type="image/ico" href="/themes/Dryad/images/favicon.ico"/>

            <script type="text/javascript" language="javascript" src="http://platform.twitter.com/widgets.js">
                <xsl:text>&#160;</xsl:text>
            </script>

            <script type="text/javascript" language="javascript" src="/themes/Dryad/lib/editor.js">
                <xsl:text>&#160;</xsl:text>
            </script>


            <script type="text/javascript" language="javascript" src="/themes/Dryad/lib/util.js">
                <xsl:text>&#160;</xsl:text>
            </script>

            <!-- Add theme javascipt  -->
            <xsl:for-each
                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
                <script type="text/javascript">
                    <xsl:attribute name="src">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    &#160;
                </script>
            </xsl:for-each>
            <!-- add "shared" javascript from static, path is relative to webapp root-->
            <xsl:for-each
                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
                <script type="text/javascript">
                    <xsl:attribute name="src">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:text>&#160;</xsl:text>
                </script>
            </xsl:for-each>

            <!-- Add a google analytics script if the key is present -->
            <xsl:if test="$meta[@element='google'][@qualifier='analytics']">
                <script type="text/javascript">
                    <xsl:text>var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");</xsl:text>
                    <xsl:text>document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));</xsl:text>
                </script>

                <script type="text/javascript">
                    <xsl:text>try {</xsl:text>
                    <xsl:text>var pageTracker = _gat._getTracker("</xsl:text><xsl:value-of
                        select="$meta[@element='google'][@qualifier='analytics']"/><xsl:text>");</xsl:text>
                    <xsl:text>pageTracker._trackPageview();</xsl:text>
                    <xsl:text>} catch(err) {}</xsl:text>
                </script>
            </xsl:if>


            <!-- Add the title in, preferring package but falling back to file, empty -->
            <xsl:variable name="pkg_page_title" select="$meta[@element='title' and not(@qualifier)]"/>
            <xsl:variable name="file_page_title" select="$meta[@element='title' and @qualifier='package']"/>
            <title>
                <xsl:choose>
                    <xsl:when test="$doc">
                        <xsl:value-of select="$doc/html/head/title"/>
                    </xsl:when>
                    <xsl:when test="$file_page_title">
                        <i18n:text>xmlui.dryad.page_title</i18n:text>
                        <xsl:value-of
                                select="//*[@id='org.datadryad.dspace.xmlui.aspect.browse.ItemViewer.div.item-view']/dri:head"/>
                    </xsl:when>
                    <xsl:when test="$pkg_page_title">
                        <xsl:copy-of select="$pkg_page_title/node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </title>

            <!-- Head metadata in item pages -->
            <xsl:if test="$meta[@element='xhtml_head_item']">
                <xsl:value-of select="$meta[@element='xhtml_head_item']" disable-output-escaping="yes"/>
            </xsl:if>

            <script type="text/javascript">jQuery.noConflict();</script>


        </head>
    </xsl:template>


    <!-- ########################################### Page Header #################################### -->
    <xsl:template name="buildHeader">
        <div id="ds-header">
            <!--add functional javasript-->
            <xsl:for-each select="$meta[@element='functjavascript']">
                <script type="text/javascript">
                    <xsl:choose>
                        <xsl:when test="@absolutePath='true'">
                            <xsl:attribute name="src">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="src">
                                <xsl:value-of select="$meta[@element='contextPath'][not(@qualifier)]"/>
                                <xsl:text>/aspects/</xsl:text>
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    &#160;
                </script>
            </xsl:for-each>
            <a>
                <xsl:attribute name="href">
                    <xsl:variable name="contextpath" select="$meta[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:choose>
                        <xsl:when test="$contextpath != ''">
                            <xsl:value-of select="$contextpath"/>
                        </xsl:when>
                        <xsl:otherwise>/dryadlab</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <img id="ds-header-logo" src="{$theme-path}/images/dryadLabLogo.png"/>
               
            </a>

            <span>
                <xsl:attribute name="class">
                    <xsl:text>ds-trail</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'] = 'submissions'">
                        <xsl:text>-shown</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) = 0">
                        <span class="ds-trail-link first-link">-</span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>

        </div>


    </xsl:template>

    <!-- ###################################################
        The template to handle dri:options. Since it contains only dri:list tags (which carry the actual
        information), the only things than need to be done is creating the ds-options div and applying
        the templates inside it.
    -->
    <xsl:template match="dri:options">
      <div id="ds-options">
	<!-- This used to simply call <xsl:apply-templates/> to process the options list sent in by the Java code.
	     For DryadLab, we build the options list manually, though we will eventually want to process the faceted 
	     search data. -->
	<h3 class="ds-option-set-head"></h3>
	<div xmlns="http://di.tamu.edu/DRI/1.0/" id="aspect_administrative_Navigation_list_account" class="ds-option-set">
	  <p />
	</div>
	<h3 class="ds-option-set-head">Information</h3>
	<div xmlns="http://di.tamu.edu/DRI/1.0/" id="aspect_administrative_Navigation_list_account" class="ds-option-set">
	  <ul class="ds-simple-list">
	    <li>
	      <a href="/">Dryad Home</a>
	    </li>
	    <li>
	      <a href="/about">About Dryad</a>
	    </li>
	  </ul>
	</div>
      </div>
    </xsl:template>


    <!-- ###################################################
  TEMPLATES THAT HIDE NORMAL DSPACE FUNCTIONALITY
  (some of these may be reinstated in the future)
  ###################################################  -->

    <!-- Related items (on item pages?) -->
    <xsl:template
            match="dri:div[@id='aspect.discovery.RelatedItems.div.test']"/>

    <!-- "old" DSpace browsing system -->
    <xsl:template
            match="dri:list[@id='org.datadryad.dspace.xmlui.aspect.browse.Navigation.list.DryadBrowse'][preceding-sibling::node()/@id='aspect.discovery.SimpleSearch.list.discovery' or following-sibling::node()/@id='aspect.discovery.SimpleSearch.list.discovery']"/>

    <!-- DSpace statistics -->
    <xsl:template
            match="dri:list[@id='aspect.statistics.Navigation.list.statistics']"/>

    <!-- Progress buttons in the submission system -->
    <xsl:template
            match="dri:list[@id='aspect.submission.StepTransformer.list.submit-progress']"/>


    <!-- capture and move notices: the message at the top of th page is dynamic to capture and move it occurs to build it dynamically and not hardcoded it. -->
    <!--xsl:template match="/dri:document/dri:body//dri:div[@id='org.datadryad.dspace.xmlui.aspect.browse.ItemViewer.div.notice'][@rend='notice']"/-->

    <xsl:template match="dri:trail">
        <span>
            <xsl:attribute name="class">
                <xsl:text>ds-trail-link </xsl:text>
                <xsl:if test="position()=1">
                    <xsl:text>first-link</xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()">
                    <xsl:text>last-link</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                    &gt;
                    <xsl:if test="position()=last() and $doc">
                        <xsl:value-of select="$doc/html/head/title"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </span>

    </xsl:template>

    <xsl:template match="dri:field[@id='aspect.submission.submit.OverviewStep.field.submit_next']">
        <input>
            <xsl:attribute name="name">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:if test="@disabled">
                <xsl:attribute name="disabled">
                    <xsl:value-of select="@disabled"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:attribute name="name">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <!--<xsl:call-template name="fieldAttributes"/>-->
            <xsl:if test="@type='button'">
                <xsl:attribute name="type">submit</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="value">
                <xsl:choose>
                    <xsl:when test="./dri:value[@type='raw']">
                        <xsl:value-of select="./dri:value[@type='raw']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./dri:value[@type='default']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="dri:value/i18n:text">
                <xsl:attribute name="i18n:attr">value</xsl:attribute>
            </xsl:if>
            <xsl:if test="dri:error">
                <span class="error">
                    <i18n:text>
                        <xsl:value-of select="dri:error"/>
                    </i18n:text>
                </span>
            </xsl:if>
            <!--<xsl:apply-templates />-->
        </input>
    </xsl:template>

    <!-- eliminate wierd font sizing algorithm see line 1362 in structural.xsl -->
    <xsl:template match="dri:div/dri:head" priority="3">
        <xsl:variable name="head_count" select="count(ancestor::dri:div)"/>
        <xsl:element name="h{$head_count}">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-div-head</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <!-- copied from structural.xsl line 2328, use to change listing behavior of nested references. -->
    <xsl:template match="dri:reference/dri:referenceSet[@type='summaryList']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <!-- Here we decide whether we have a hierarchical list or a flat one -->
        <xsl:choose>
            <xsl:when
                    test="descendant-or-self::dri:referenceSet/@rend='hierarchy' or ancestor::dri:referenceSet/@rend='hierarchy'">
                <ul>
                    <xsl:apply-templates select="*[not(name()='head')]" mode="summaryList"/>
                </ul>
            </xsl:when>
            <xsl:otherwise>

                <!-- we can drop javascript / css handlers in here to toggle lists of sub items... -->
                <ul class="ds-artifact-list">
                    <xsl:apply-templates select="*[not(name()='head')]" mode="summaryList"/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        This will resolve any nested summaryList
        reference tag to a mets document and apply a new mode for nested items.

    -->
    <xsl:template match="dri:reference/dri:referenceSet[@type='summaryList']/dri:reference"
                  mode="summaryList">
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="@url"/>
            <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
            <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
            <xsl:if test="@type='DSpace Item'">
                <xsl:text>&amp;dmdTypes=DC</xsl:text>
            </xsl:if>-->
        </xsl:variable>
        <xsl:comment>External Metadata URL:
            <xsl:value-of select="$externalMetadataURL"/>
        </xsl:comment>
        <li>
            <xsl:attribute name="class">
                <xsl:text>ds-artifact-item </xsl:text>
                <xsl:choose>
                    <xsl:when test="position() mod 2 = 0">even</xsl:when>
                    <xsl:otherwise>odd</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="document($externalMetadataURL)//dim:dim" mode="nestedSummaryList"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <!--
        This is used for subitems in groups publications (subitems may be any type).
        Alter this to change the fields shown for subitems of groups
    -->
    <xsl:template match="dim:dim" mode="nestedSummaryList">
        <xsl:variable name="type">
            <xsl:value-of select="dim:field[@element='type' and @mdschema='dc']"/>
        </xsl:variable>
        <xsl:attribute name="class">
            <xsl:text>ds-artifact-item even</xsl:text>
        </xsl:attribute>
        <xsl:variable name="doiIdentifier"
                      select=".//dim:field[@element='identifier'][@mdschema='dc'][not(@qualifier)]"/>
        <xsl:variable name="itemWithdrawn" select="@withdrawn"/>
        <div>
            <xsl:attribute name="class">artifact-description dataset</xsl:attribute>
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                <xsl:text>&#160;</xsl:text>
            </span>
            <div class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="$itemWithdrawn">
                                <xsl:value-of select="ancestor::mets:METS/@OBJEDIT"/>
                            </xsl:when>
                            <xsl:when test="$doiIdentifier">
                                <xsl:text>/resource/</xsl:text>
                                <xsl:copy-of
                                        select=".//dim:field[@element='identifier'][@mdschema='dc'][not(@qualifier)]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="ancestor::mets:METS/@OBJID"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </div>
        </div>
    </xsl:template>


    <!-- Rendering table for Full Metadata view -->
    <xsl:template match="dim:field" mode="itemDetailView-DIM">
        <xsl:if test="not(./@qualifier = 'manuscriptNumber')">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even</xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd</xsl:if>
                </xsl:attribute>
                <td>
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
                <td>
                    <xsl:copy-of select="./node()"/>
                </td>
                <td>
                    <xsl:value-of select="./@language"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    
    <!-- Don't render the "Submit Data Now" button -->
    <xsl:template match="dri:xref[../../@id='aspect.submission.Navigation.list.submitNow']" /> 


    <!-- ignore the hierarchy so no collection displays on item pages: ticket 1351 -->
    <xsl:template match="dri:referenceSet[@rend='hierarchy'][@type='detailList']" />


    <!-- Overwriting the structural XSL's general paragraph processing -->
    <xsl:template match="dri:p">
        <xsl:choose>
            <!-- don't process (ignore) top item-view-toggle - ticket 1345 -->
            <xsl:when test="@rend='item-view-toggle item-view-toggle-top'"/>
            <xsl:otherwise>
                <p>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">ds-paragraph</xsl:with-param>
                    </xsl:call-template>
                    <xsl:choose>
                        <!--  does this element have any children -->
                        <xsl:when test="child::node()">
                            <xsl:apply-templates/>
                        </xsl:when>
                        <!-- if no children are found we add a space to eliminate self closing tags -->
                        <xsl:otherwise> &#160; </xsl:otherwise>
                    </xsl:choose>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template
            match="dri:field[@id='aspect.administrative.collection.SetupCollectionHarvestingForm.field.oai-set-comp' and @type='composite']"
            mode="formComposite" priority="2">
        <xsl:for-each select="dri:field[@type='radio']">
            <div class="ds-form-content">
                <xsl:for-each select="dri:option">
                    <input type="radio">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@returnValue"/>
                        </xsl:attribute>
                        <xsl:attribute name="name">
                            <xsl:value-of select="../@n"/>
                        </xsl:attribute>
                        <xsl:attribute name="value">
                            <xsl:value-of select="@returnValue"/>
                        </xsl:attribute>
                        <xsl:if test="../dri:value[@type='option'][@option = current()/@returnValue]">
                            <xsl:attribute name="checked">checked</xsl:attribute>
                        </xsl:if>
                    </input>
                    <label>
                        <xsl:attribute name="for">
                            <xsl:value-of select="@returnValue"/>
                        </xsl:attribute>
                        <xsl:value-of select="text()"/>
                    </label>
                    <xsl:if test="@returnValue = 'specific'">
                        <xsl:apply-templates select="../../dri:field[@n='oai_setid']"/>
                    </xsl:if>
                    <br/>
                </xsl:for-each>
            </div>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="dri:field" mode="normalField">
        <xsl:variable name="confidenceIndicatorID"
                      select="concat(translate(@id,'.','_'),'_confidence_indicator')"/>
        <xsl:choose>
            <!-- TODO: this has changed drammatically (see form3.xml) -->
            <xsl:when test="@type= 'select'">
                <select>
                    <xsl:call-template name="fieldAttributes"/>
                    <xsl:apply-templates/>
                    <xsl:if test="not(dri:option)">
                        <option value=""/>
                    </xsl:if>
                </select>
            </xsl:when>
            <xsl:when test="@type= 'textarea'">
                <textarea>
                    <xsl:call-template name="fieldAttributes"/>
                    <xsl:if
                            test="ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset']">
                        <xsl:if test="dri:help">
                            <xsl:attribute name="title">
                                <xsl:value-of select="dri:help"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="../dri:help">
                            <xsl:attribute name="title">
                                <xsl:value-of select="../dri:help"/>
                            </xsl:attribute>
                        </xsl:if>
                    </xsl:if>
                    <!--
                       if the cols and rows attributes are not defined we need to call
                       the tempaltes for them since they are required attributes in strict xhtml
                    -->
                    <xsl:choose>
                        <xsl:when test="not(./dri:params[@cols])">
                           <!-- <xsl:call-template name="textAreaCols"/>  -->  
                           <!-- override to Dryad specific value - maybe this can be refined in if makes things ugly-->
                           <xsl:attribute name="cols">60</xsl:attribute>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="not(./dri:params[@rows])">
                            <xsl:call-template name="textAreaRows"/>
                        </xsl:when>
                    </xsl:choose>

                    <xsl:apply-templates/>
                    <xsl:choose>
                        <xsl:when test="./dri:value[@type='raw']">
                            <xsl:copy-of select="./dri:value[@type='raw']/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="./dri:value[@type='default']/node()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="string-length(./dri:value) &lt; 1">
                        <i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>
                    </xsl:if>
                </textarea>


                <!-- add place to store authority value -->
                <xsl:if test="dri:params/@authorityControlled">
                    <xsl:variable name="confidence">
                        <xsl:if test="./dri:value[@type='authority']">
                            <xsl:value-of select="./dri:value[@type='authority']/@confidence"/>
                        </xsl:if>
                    </xsl:variable>
                    <!-- add authority confidence widget -->
                    <xsl:call-template name="authorityConfidenceIcon">
                        <xsl:with-param name="confidence" select="$confidence"/>
                        <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                    </xsl:call-template>
                    <xsl:call-template name="authorityInputFields">
                        <xsl:with-param name="name" select="@n"/>
                        <xsl:with-param name="id" select="@id"/>
                        <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                        <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                        <xsl:with-param name="confIndicatorID" select="$confidenceIndicatorID"/>
                        <xsl:with-param name="unlockButton"
                                        select="dri:value[@type='authority']/dri:field[@rend='ds-authority-lock']/@n"/>
                        <xsl:with-param name="unlockHelp"
                                        select="dri:value[@type='authority']/dri:field[@rend='ds-authority-lock']/dri:help"/>
                    </xsl:call-template>
                </xsl:if>
                <!-- add choice mechanisms -->
                <xsl:choose>
                    <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                        <xsl:call-template name="addAuthorityAutocomplete">
                            <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                            <xsl:with-param name="confidenceName">
                                <xsl:value-of select="concat(@n,'_confidence')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                        <xsl:call-template name="addLookupButton">
                            <xsl:with-param name="isName" select="'false'"/>
                            <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="@type= 'checkbox' or @type= 'radio'">
                <fieldset>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">
                            <xsl:text>ds-</xsl:text>
                            <xsl:value-of select="@type"/>
                            <xsl:text>-field </xsl:text>
                            <xsl:if test="dri:error">
                                <xsl:text>error </xsl:text>
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:attribute name="id">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <xsl:if test="dri:label">
                        <legend>
                            <xsl:apply-templates select="dri:label" mode="compositeComponent"/>
                        </legend>
                    </xsl:if>
                    <xsl:apply-templates/>
                </fieldset>
            </xsl:when>

            <xsl:when test="@type= 'composite'">
                <!-- TODO: add error and help stuff on top of the composite -->
                <span class="ds-composite-field">
                    <xsl:apply-templates select="dri:field" mode="compositeComponent"/>
                </span>
                <xsl:apply-templates select="dri:field/dri:error" mode="compositeComponent"/>
                <xsl:apply-templates select="dri:error" mode="compositeComponent"/>
                <xsl:apply-templates select="dri:field/dri:help" mode="compositeComponent"/>
                <!--<xsl:apply-templates select="dri:help" mode="compositeComponent"/>-->
            </xsl:when>
            <!-- text, password, file, and hidden types are handled the same.
                Buttons: added the xsl:if check which will override the type attribute button
                    with the value 'submit'. No reset buttons for now...
            -->
            <xsl:otherwise>
                <input>
                    <xsl:call-template name="fieldAttributes"/>
                    <xsl:if test="@type='button'">
                        <xsl:attribute name="type">submit</xsl:attribute>
                    </xsl:if>
                    <xsl:if
                            test="ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset']">
                        <xsl:if test="dri:help">
                            <xsl:attribute name="title">
                                <xsl:value-of select="dri:help"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="../dri:help">
                            <xsl:attribute name="title">
                                <xsl:value-of select="../dri:help"/>
                            </xsl:attribute>
                        </xsl:if>
                    </xsl:if>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="./dri:value[@type='raw']">
                                <xsl:value-of select="./dri:value[@type='raw']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./dri:value[@type='default']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="dri:value/i18n:text">
                        <xsl:attribute name="i18n:attr">value</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </input>

                <xsl:variable name="confIndicatorID" select="concat(@id,'_confidence_indicator')"/>
                <xsl:if test="dri:params/@authorityControlled">
                    <xsl:variable name="confidence">
                        <xsl:if test="./dri:value[@type='authority']">
                            <xsl:value-of select="./dri:value[@type='authority']/@confidence"/>
                        </xsl:if>
                    </xsl:variable>
                    <!-- add authority confidence widget -->
                    <xsl:call-template name="authorityConfidenceIcon">
                        <xsl:with-param name="confidence" select="$confidence"/>
                        <xsl:with-param name="id" select="$confidenceIndicatorID"/>
                    </xsl:call-template>
                    <xsl:call-template name="authorityInputFields">
                        <xsl:with-param name="name" select="@n"/>
                        <xsl:with-param name="id" select="@id"/>
                        <xsl:with-param name="authValue" select="dri:value[@type='authority']/text()"/>
                        <xsl:with-param name="confValue" select="dri:value[@type='authority']/@confidence"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="dri:params/@choicesPresentation = 'suggest'">
                        <xsl:call-template name="addAuthorityAutocomplete">
                            <xsl:with-param name="confidenceIndicatorID" select="$confidenceIndicatorID"/>
                            <xsl:with-param name="confidenceName">
                                <xsl:value-of select="concat(@n,'_confidence')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="dri:params/@choicesPresentation = 'lookup'">
                        <xsl:call-template name="addLookupButton">
                            <xsl:with-param name="isName" select="'false'"/>
                            <xsl:with-param name="confIndicator" select="$confidenceIndicatorID"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template
            match="dri:list[@id='aspect.submission.StepTransformer.list.journal-select-sublist']">
        <ul>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class"></xsl:with-param>
            </xsl:call-template>
            <xsl:for-each select="dri:item">
                <li>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class"></xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="pick-label"/>
                    <div class="ds-form-content">
                        <xsl:apply-templates/>
                        <!-- special name used in submission UI review page -->
                        <xsl:if test="@n = 'submit-review-field-with-authority'">
                            <xsl:call-template name="authorityConfidenceIcon">
                                <xsl:with-param name="confidence" select="substring-after(./@rend, 'cf-')"/>
                            </xsl:call-template>
                        </xsl:if>
                    </div>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>


    <!-- ############################################# Discovery rendering ####################################### -->
    <xsl:template match="dri:field[@id='aspect.discovery.SiteViewer.field.submit']">
        <input>
            <xsl:call-template name="fieldAttributes"/>
            <xsl:if test="@type='button'">
                <xsl:attribute name="type">submit</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="value">xmlui.discovery.SiteViewer.go</xsl:attribute>
            <xsl:if test="dri:value/i18n:text">
                <xsl:attribute name="i18n:attr">value</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </input>
    </xsl:template>

    <xsl:template match="dri:field[@id='aspect.discovery.SimpleSearch.field.query']">
        <xsl:variable name="query">
            <xsl:call-template name="parse-query-param">
                <xsl:with-param name="param-name">query</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <span>
            <xsl:value-of select="$query"/>
        </span>
        <input
                id="aspect_discovery_SimpleSearch_field_query"
                class="ds-text-field" name="query"
                type="hidden" value="{$query}"/>
    </xsl:template>

    <xsl:template match="dri:field[@id='aspect.discovery.SimpleSearch.field.submit']">
        <!-- Would fit better in Java, but trying to avoid touching discovery code -->
        <xsl:variable name="location">
            <xsl:call-template name="parse-query-param">
                <xsl:with-param name="param-name">location</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$location != ''">
                <xsl:element name="input">
                    <xsl:attribute name="type">hidden</xsl:attribute>
                    <xsl:attribute name="name">location</xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$location"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <input name="location" type="hidden" value="l2"/>
            </xsl:otherwise>
        </xsl:choose>
        <input>
            <xsl:call-template name="fieldAttributes"/>
            <xsl:if test="@type='button'">
                <xsl:attribute name="type">submit</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="value">xmlui.discovery.SimpleSearch.go</xsl:attribute>
            <xsl:if test="dri:value/i18n:text">
                <xsl:attribute name="i18n:attr">value</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </input>
        <a href="/searching" alt="How searching works in Dryad">
            <img src="/themes/Dryad/images/help.png" alt="How searching works in Dryad"/>
        </a>
    </xsl:template>

    <!-- ################################################### Random Utility Stuff ################################################### -->

    <xsl:template match="dri:help" mode="help">
        <xsl:if
                test="not(ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset'])">
            <!--Only create the <span> if there is content in the <dri:help> node-->
            <xsl:if test="./text() or ./node()">
                <span>
                    <xsl:attribute name="class">
                        <xsl:text>field-help</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dri:help" mode="compositeComponent">
        <xsl:if
                test="not(ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset'])">
            <span class="composite-help">
                <xsl:if
                        test="ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset']">
                    <xsl:variable name="translatedParentId">
                        <xsl:value-of select="translate(../@id, '.', '_')"/>
                    </xsl:variable>
                    <xsl:attribute name="connectId">
                        <xsl:value-of select="$translatedParentId"/>
                    </xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$translatedParentId"
                            />_tooltip
                    </xsl:attribute>
                </xsl:if>

                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dri:item[@id='aspect.submission.StepTransformer.item.data-upload-details']">
        <div class="ds-form-content">
            <i18n:text>
                <xsl:value-of select="."/>
            </i18n:text>
        </div>
    </xsl:template>

    <xsl:template match="dri:list[@id='aspect.submission.StepTransformer.list.submit-upload-file']">
        <fieldset>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">
                    <!-- Provision for the sub list -->
                    <xsl:text>ds-form-</xsl:text>
                    <xsl:if test="ancestor::dri:list[@type='form']">
                        <xsl:text>sub</xsl:text>
                    </xsl:if>
                    <xsl:text>list </xsl:text>
                    <xsl:if test="count(dri:item) > 3">
                        <xsl:text>thick </xsl:text>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="dri:head"/>

            <xsl:apply-templates select="dri:item[@id='aspect.submission.StepTransformer.item.data-upload-details']"/>

            <table class="datafiletable">
                <tr>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-item']/dri:field[@type='radio']"
                                />
                    </td>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-item']/*[not(@type='radio')]"
                                />
                    </td>
                </tr>
                <tr>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-identifier']/dri:field[@type='radio']"
                                />
                    </td>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-identifier']/*[not(@type='radio')]"
                                />
                    </td>
                </tr>
            </table>
        </fieldset>
    </xsl:template>

    <!-- Build a single row in the bitsreams table of the item view page -->
    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() mod 2 = 0)">even</xsl:if>
                <xsl:if test="(position() mod 2 = 1)">odd</xsl:if>
            </xsl:attribute>
            <td>
                <xsl:choose>
                    <xsl:when test="mets:FLocat[@LOCTYPE='URL']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="string-length(mets:FLocat[@LOCTYPE='URL']/@xlink:title) > 50">
                                    <xsl:variable name="title_length"
                                                  select="string-length(mets:FLocat[@LOCTYPE='URL']/@xlink:title)"/>
                                    <xsl:value-of select="substring(mets:FLocat[@LOCTYPE='URL']/@xlink:title,1,15)"/>
                                    <xsl:text> ... </xsl:text>
                                    <xsl:value-of
                                            select="substring(mets:FLocat[@LOCTYPE='URL']/@xlink:title,$title_length - 25,$title_length)"
                                            />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='TXT']/@xlink:text"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- File size always comes in bytes and thus needs conversion -->
            <td>
                <xsl:choose>
                    <xsl:when test="@SIZE &lt; 1000">
                        <xsl:value-of select="@SIZE"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1000000">
                        <xsl:value-of select="substring(string(@SIZE div 1000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1000000000">
                        <xsl:value-of select="substring(string(@SIZE div 1000000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string(@SIZE div 1000000000),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- Lookup File Type description in local messages.xml based on MIME Type.
     In the original DSpace, this would get resolved to an application via
     the Bitstream Registry, but we are constrained by the capabilities of METS
     and can't really pass that info through. -->
            <td>
                <xsl:call-template name="getFileTypeDesc">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when
                            test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                        <a class="image-link">
                            <xsl:attribute name="href">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of
                                            select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                        mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"
                                            />
                                </xsl:attribute>
                            </img>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="mets:FLocat[@LOCTYPE='URL']">
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                                </a>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- Display the contents of 'Description' as long as at least one bitstream contains a description -->
            <xsl:if
                    test="$context/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:label != ''">
                <td>
                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                </td>
            </xsl:if>

        </tr>
    </xsl:template>

    <!-- RestrictItem: template used for dispalying the right page based upon the item state stored in the metadatapage dryad.itemState -->
    <xsl:template match="dri:div[@n='workflow_pendingPublicationStep']/dri:head" priority="100">
        <xsl:variable name="head_count" select="count(ancestor::dri:div)"/>
        <xsl:element name="h{$head_count}">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-div-head</xsl:with-param>
            </xsl:call-template>
            <i18n:text>xmlui.aspect.artifactbrowser.RestrictedItem.div.pendingPublicationStep-resource.head</i18n:text>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dri:div[@n='workflow_pendingPublicationStep']/dri:p[1]" priority="100">
        <p>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-paragraph</xsl:with-param>
            </xsl:call-template>
            <i18n:text>xmlui.aspect.artifactbrowser.RestrictedItem.div.pendingPublicationStep-resource.body</i18n:text>
        </p>
    </xsl:template>

    <xsl:template match="dri:div[@n='workflow_pendingPublicationStep']/dri:p[@n='item_status']" priority="100">
        <p>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">ds-paragraph</xsl:with-param>
            </xsl:call-template>
            <i18n:text>xmlui.aspect.artifactbrowser.RestrictedItem.div.pendingPublicationStep-resource.status
            </i18n:text>
        </p>
        <p>
            <i18n:text>xmlui.aspect.artifactbrowser.RestrictedItem.div.pendingPublicationStep-resource.help</i18n:text>

        </p>

    </xsl:template>


    <!-- Quick patch to remove empty lists from options -->
    <xsl:template match="dri:options//dri:list[count(child::*)=0]" priority="5" mode="nested"></xsl:template>
    <xsl:template match="dri:options//dri:list[count(child::*)=0]" priority="5"></xsl:template>


    <!-- generate the script that sets up autocomplete feature on input field -->
    <!-- ..it has lots of params -->
    <xsl:template name="autocompleteSetup">
        <xsl:param name="formID" select="'missing value'"/>
        <xsl:param name="metadataField" select="'missing value'"/>
        <xsl:param name="inputName" select="'missing value'"/>
        <xsl:param name="authorityName" select="''"/>
        <xsl:param name="containerID" select="'missing value'"/>
        <xsl:param name="collectionID" select="'-1'"/>
        <xsl:param name="indicatorID" select="'missing value'"/>
        <xsl:param name="confidenceIndicatorID" select="''"/>
        <xsl:param name="confidenceName" select="''"/>
        <xsl:param name="isClosed" select="'false'"/>

        <!-- CALLING THE FUNCTION WITHOUT OVERRIDING THE OnLoad() method -->
        <script type="text/javascript">

            <xsl:text>jQuery(document).ready(function() {</xsl:text>
            <xsl:text>var gigo = DSpaceSetupAutocomplete('</xsl:text>
            <xsl:value-of select="$formID"/>
            <xsl:text>', { metadataField: '</xsl:text>
            <xsl:value-of select="$metadataField"/>
            <xsl:text>', isClosed: '</xsl:text>
            <xsl:value-of select="$isClosed"/>
            <xsl:text>', inputName: '</xsl:text>
            <xsl:value-of select="$inputName"/>
            <xsl:text>', authorityName: '</xsl:text>
            <xsl:value-of select="$authorityName"/>
            <xsl:text>', containerID: '</xsl:text>
            <xsl:value-of select="$containerID"/>
            <xsl:text>', indicatorID: '</xsl:text>
            <xsl:value-of select="$indicatorID"/>
            <xsl:text>', confidenceIndicatorID: '</xsl:text>
            <xsl:value-of select="$confidenceIndicatorID"/>
            <xsl:text>', confidenceName: '</xsl:text>
            <xsl:value-of select="$confidenceName"/>
            <xsl:text>', collection: </xsl:text>
            <xsl:value-of select="$collectionID"/>
            <xsl:text>, contextPath: '</xsl:text>
            <xsl:value-of
                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
            <xsl:text>'});</xsl:text>
            <xsl:text>});</xsl:text>
        </script>



    </xsl:template>

</xsl:stylesheet>
