<%
/**
 * Copyright (c) 2000-2009 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/html/portlet/wiki/init.jsp" %>

<%
WikiNode node = (WikiNode)request.getAttribute(WebKeys.WIKI_NODE);
WikiPage wikiPage = (WikiPage)request.getAttribute(WebKeys.WIKI_PAGE);

String type = ParamUtil.getString(request, "type");
String categoryId = ParamUtil.getString(request, "categoryId");
String tagName = ParamUtil.getString(request, "tag");

PortletURL portletURL = renderResponse.createRenderURL();

if (type.equals("all_pages")) {
	portletURL.setParameter("struts_action", "/wiki/view_all_pages");
}
else if (type.equals("categorized_pages")) {
	portletURL.setParameter("struts_action", "/wiki/view_categorized_pages");
	portletURL.setParameter("categoryId", categoryId);
}
else if (type.equals("history")) {
	portletURL.setParameter("struts_action", "/wiki/view_page_history");
}
else if (type.equals("incoming_links")) {
	portletURL.setParameter("struts_action", "/wiki/view_page_incoming_links");
}
else if (type.equals("orphan_pages")) {
	portletURL.setParameter("struts_action", "/wiki/view_orphan_pages");
}
else if (type.equals("outgoing_links")) {
	portletURL.setParameter("struts_action", "/wiki/view_page_outgoing_links");
}
else if (type.equals("recent_changes")) {
	portletURL.setParameter("struts_action", "/wiki/view_recent_changes");
}
else if (type.equals("tagged_pages")) {
	portletURL.setParameter("struts_action", "/wiki/view_tagged_pages");
	portletURL.setParameter("tag", tagName);
}

portletURL.setParameter("nodeId", String.valueOf(node.getNodeId()));

if (wikiPage != null) {
	portletURL.setParameter("title", wikiPage.getTitle());
}
%>

<c:if test='<%= type.equals("history") %>'>
	<script type="text/javascript">
		function <portlet:namespace />compare() {
			var rowIds = jQuery('input[name=<portlet:namespace />rowIds]:checked');
			var sourceVersion = jQuery('input[name="<portlet:namespace />sourceVersion"]');
			var targetVersion = jQuery('input[name="<portlet:namespace />targetVersion"]');

			if (rowIds.length == 1) {
				sourceVersion.val(rowIds[0].value);
			}
			else if (rowIds.length == 2) {
				sourceVersion.val(rowIds[1].value);
				targetVersion.val(rowIds[0].value);
			}

			submitForm(document.<portlet:namespace />fm);
		}

		function <portlet:namespace />initRowsChecked() {
			var rowIds = jQuery('input[name=<portlet:namespace />rowIds]');

			var found = 0;

			for (i = 0; i < rowIds.length; i++) {
				if (rowIds[i].checked && (found < 2)) {
					found++;
				}
				else {
					rowIds[i].checked = false;
				}
			}
		}

		function <portlet:namespace />updateRowsChecked(element) {
			var rowsChecked = jQuery('input[name=<portlet:namespace />rowIds]:checked');

			if (rowsChecked.length > 2) {
				if (rowsChecked[2] == element) {
					rowsChecked[1].checked = false;
				}
				else {
					rowsChecked[2].checked = false;
				}
			}
		}

		jQuery(
			function() {
				<portlet:namespace />initRowsChecked();

				jQuery('input[name=<portlet:namespace />rowIds]').click(
					function() {
						<portlet:namespace />updateRowsChecked(this);
					}
				);
			}
		);
	</script>
</c:if>

<%
List<String> headerNames = new ArrayList<String>();

headerNames.add("page");
headerNames.add("revision");
headerNames.add("user");
headerNames.add("date");

if (type.equals("history") || type.equals("recent_changes")) {
	headerNames.add("summary");
}

if (type.equals("all_pages") || type.equals("history") || type.equals("orphan_pages") || type.equals("recent_changes") || type.equals("tagged_pages")) {
	headerNames.add(StringPool.BLANK);
}

String emptyResultsMessage = null;

if (type.equals("incoming_links")) {
	emptyResultsMessage = "there-are-no-pages-that-link-to-this-page";
}
else if (type.equals("outgoing_links")) {
	emptyResultsMessage = "this-page-has-no-links";
}
else if (type.equals("recent_changes")) {
	emptyResultsMessage = "there-are-no-recent-changes";
}
else if (type.equals("tagged_pages")) {
	emptyResultsMessage = "there-are-no-pages-with-this-tag";
}

SearchContainer searchContainer = new SearchContainer(renderRequest, null, null, SearchContainer.DEFAULT_CUR_PARAM, SearchContainer.DEFAULT_DELTA, portletURL, headerNames, emptyResultsMessage);

if (type.equals("history")) {
	searchContainer.setRowChecker(new RowChecker(renderResponse, RowChecker.ALIGN, RowChecker.VALIGN, RowChecker.FORM_NAME, null, RowChecker.ROW_IDS));
}

int total = 0;
List<WikiPage> results = null;

if (type.equals("all_pages")) {
	total = WikiPageLocalServiceUtil.getPagesCount(node.getNodeId(), true);
	results = WikiPageLocalServiceUtil.getPages(node.getNodeId(), true, searchContainer.getStart(), searchContainer.getEnd());
}
else if (type.equals("categorized_pages") || type.equals("tagged_pages")) {
	AssetEntryQuery assetEntryQuery = new AssetEntryQuery(WikiPage.class.getName(), searchContainer);

	total = AssetEntryLocalServiceUtil.getEntriesCount(assetEntryQuery);
	List<AssetEntry> assetEntries = AssetEntryLocalServiceUtil.getEntries(assetEntryQuery);

	results = new ArrayList<WikiPage>();

	for (AssetEntry assetEntry : assetEntries) {
		WikiPageResource pageResource = WikiPageResourceLocalServiceUtil.getPageResource(assetEntry.getClassPK());

		WikiPage assetPage = WikiPageLocalServiceUtil.getPage(pageResource.getNodeId(), pageResource.getTitle());

		results.add(assetPage);
	}
}
else if (type.equals("orphan_pages")) {
	List<WikiPage> orphans = WikiPageLocalServiceUtil.getOrphans(node.getNodeId());

	total = orphans.size();
	results = ListUtil.subList(orphans, searchContainer.getStart(), searchContainer.getEnd());
}
else if (type.equals("history")) {
	total = WikiPageLocalServiceUtil.getPagesCount(wikiPage.getNodeId(), wikiPage.getTitle());
	results = WikiPageLocalServiceUtil.getPages(wikiPage.getNodeId(), wikiPage.getTitle(), QueryUtil.ALL_POS, QueryUtil.ALL_POS, new PageVersionComparator());
}
else if (type.equals("incoming_links")) {
	List<WikiPage> links = WikiPageLocalServiceUtil.getIncomingLinks(wikiPage.getNodeId(), wikiPage.getTitle());

	total = links.size();
	results = ListUtil.subList(links, searchContainer.getStart(), searchContainer.getEnd());
}
else if (type.equals("outgoing_links")) {
	List<WikiPage> links = WikiPageLocalServiceUtil.getOutgoingLinks(wikiPage.getNodeId(), wikiPage.getTitle());

	total = links.size();
	results = ListUtil.subList(links, searchContainer.getStart(), searchContainer.getEnd());
}
else if (type.equals("recent_changes")) {
	total = WikiPageLocalServiceUtil.getRecentChangesCount(node.getNodeId());
	results = WikiPageLocalServiceUtil.getRecentChanges(node.getNodeId(), searchContainer.getStart(), searchContainer.getEnd());
}

searchContainer.setTotal(total);
searchContainer.setResults(results);

List resultRows = searchContainer.getResultRows();

for (int i = 0; i < results.size(); i++) {
	WikiPage curWikiPage = results.get(i);

	curWikiPage = curWikiPage.toEscapedModel();

	ResultRow row = new ResultRow(curWikiPage, String.valueOf(curWikiPage.getVersion()), i);

	PortletURL rowURL = renderResponse.createRenderURL();

	if (!curWikiPage.isNew()) {
		rowURL.setParameter("struts_action", "/wiki/view");
		rowURL.setParameter("nodeName", curWikiPage.getNode().getName());
	}
	else {
		rowURL.setParameter("struts_action", "/wiki/edit_page");
		rowURL.setParameter("nodeId", String.valueOf(curWikiPage.getNodeId()));
	}

	rowURL.setParameter("title", HtmlUtil.unescape(curWikiPage.getTitle()));

	if (type.equals("history")) {
		rowURL.setParameter("version", String.valueOf(curWikiPage.getVersion()));
	}

	// Title

	row.addText(curWikiPage.getTitle(), rowURL);

	// Revision

	if (!curWikiPage.isNew()) {
		String revision = String.valueOf(curWikiPage.getVersion());

		if (curWikiPage.isMinorEdit()) {
			revision += " (" + LanguageUtil.get(pageContext, "minor-edit") + ")";
		}

		row.addText(revision, rowURL);
	}
	else {
		row.addText(StringPool.BLANK);
	}

	// User

	if (!curWikiPage.isNew()) {
		row.addText(PortalUtil.getUserName(curWikiPage.getUserId(), curWikiPage.getUserName()), rowURL);
	}
	else {
		row.addText(StringPool.BLANK);
	}

	// Date

	if (!curWikiPage.isNew()) {
		row.addText(dateFormatDateTime.format(curWikiPage.getCreateDate()), rowURL);
	}
	else {
		row.addText(StringPool.BLANK);
	}

	// Summary

	if (type.equals("history") || type.equals("recent_changes")) {
		if (Validator.isNotNull(curWikiPage.getSummary())) {
			row.addText(curWikiPage.getSummary());
		}
		else {
			row.addText(StringPool.BLANK);
		}
	}

	// Action

	if (type.equals("history")) {
		if (curWikiPage.isHead()) {
			row.addText(StringPool.BLANK);
		}
		else {
			row.addJSP("right", SearchEntry.DEFAULT_VALIGN, "/html/portlet/wiki/page_history_action.jsp");
		}
	}

	if (type.equals("all_pages") || type.equals("orphan_pages") || type.equals("recent_changes") || type.equals("tagged_pages")) {
		row.addJSP("right", SearchEntry.DEFAULT_VALIGN, "/html/portlet/wiki/page_action.jsp");
	}

	// Add result row

	resultRows.add(row);
}
%>

<c:if test='<%= type.equals("history") && (results.size() > 1) %>'>

	<%
	WikiPage latestWikiPage = (WikiPage)results.get(1);
	%>

	<portlet:renderURL var="compareVersionsURL">
		<portlet:param name="struts_action" value="/wiki/compare_versions" />
	</portlet:renderURL>

	<aui:form action="<%= compareVersionsURL %>" method="post" name="fm" onSubmit='<%= renderResponse.getNamespace() + "compare(); return false;" %>'>
		<aui:input name="backURL" type="hidden" value="<%= currentURL %>" />
		<aui:input name="nodeId" type="hidden" value="<%= node.getNodeId() %>" />
		<aui:input name="title" type="hidden" value="<%= wikiPage.getTitle() %>" />
		<aui:input name="sourceVersion" type="hidden" value="<%= latestWikiPage.getVersion() %>" />
		<aui:input name="targetVersion" type="hidden" value="<%= wikiPage.getVersion() %>" />
		<aui:input name="type" type="hidden" value="html" />

		<aui:button-row>
			<aui:button name="submitButton" type="submit" value="compare-versions" />
		</aui:button-row>
	</aui:form>
</c:if>

<c:if test='<%= type.equals("all_pages") && WikiNodePermission.contains(permissionChecker, node.getNodeId(), ActionKeys.ADD_PAGE) %>'>
	<aui:button-row>
		<portlet:actionURL var="addPageURL">
			<portlet:param name="struts_action" value="/wiki/edit_page" />
			<portlet:param name="nodeId" value="<%= String.valueOf(node.getNodeId()) %>" />
			<portlet:param name="editTitle" value="1" />
		</portlet:actionURL>

		<aui:button name="addPageButton" onClick="<%= addPageURL %>" type="button" value="add-page" />
	</aui:button-row>
</c:if>

<liferay-ui:search-iterator searchContainer="<%= searchContainer %>" paginate='<%= type.equals("history") ? false : true %>' />