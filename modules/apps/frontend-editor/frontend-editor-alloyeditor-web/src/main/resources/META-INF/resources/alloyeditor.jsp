<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<%
String portletId = portletDisplay.getId();

boolean autoCreate = GetterUtil.getBoolean((String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":autoCreate"));
String contents = GetterUtil.getString((String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":contents"));
String contentsLanguageId = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":contentsLanguageId");
String cssClass = GetterUtil.getString((String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":cssClass"));
Map<String, Object> data = (Map<String, Object>)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":data");
String editorName = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":editorName");
String initMethod = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":initMethod");
String name = namespace + GetterUtil.getString((String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":name"));
String onBlurMethod = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":onBlurMethod");
String onChangeMethod = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":onChangeMethod");
String onFocusMethod = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":onFocusMethod");
String onInitMethod = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":onInitMethod");
String placeholder = GetterUtil.getString((String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":placeholder"));
String required = (String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":required");
boolean showSource = GetterUtil.getBoolean((String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":showSource"));
boolean skipEditorLoading = GetterUtil.getBoolean((String)request.getAttribute(AlloyEditorConstants.ATTRIBUTE_NAMESPACE + ":skipEditorLoading"));

JSONObject editorConfigJSONObject = null;

if (data != null) {
	editorConfigJSONObject = (JSONObject)data.get("editorConfig");
}

EditorOptions editorOptions = null;

if (data != null) {
	editorOptions = (EditorOptions)data.get("editorOptions");
}

Map<String, Object> editorOptionsDynamicAttributes = null;

if (editorOptions != null) {
	editorOptionsDynamicAttributes = editorOptions.getDynamicAttributes();
}
%>

<c:if test="<%= !skipEditorLoading %>">
	<liferay-editor:resources
		editorName="<%= editorName %>"
	/>
</c:if>

<script data-senna-track="temporary" type="text/javascript">
	CKEDITOR.disableAutoInline = true;

	CKEDITOR.env.isCompatible = true;
</script>

<liferay-util:buffer
	var="alloyEditor"
>
	<div class="alloy-editor alloy-editor-placeholder <%= HtmlUtil.escapeAttribute(cssClass) %>" contenteditable="false" data-placeholder="<%= LanguageUtil.get(request, placeholder) %>" data-required="<%= required %>" id="<%= HtmlUtil.escapeAttribute(name) %>" name="<%= HtmlUtil.escapeAttribute(name) %>"></div>

	<aui:icon cssClass="alloy-editor-icon" image="text-editor" markupView="lexicon" />
</liferay-util:buffer>

<liferay-util:buffer
	var="editor"
>
	<c:choose>
		<c:when test="<%= showSource %>">
			<div class="alloy-editor-wrapper" id="<%= HtmlUtil.escapeAttribute(name) %>Wrapper">
				<div class="wrapper">
					<%= alloyEditor %>

					<div id="<%= HtmlUtil.escapeAttribute(name) %>Source">
						<div class="lfr-source-editor-code"></div>
					</div>
				</div>
			</div>

			<div class="alloy-editor-switch hide">
				<button class="btn btn-default btn-xs hide lfr-portal-tooltip" data-title="<%= LanguageUtil.get(resourceBundle, "fullscreen") %>" id="<%= HtmlUtil.escapeAttribute(name) %>Fullscreen" type="button">
					<aui:icon cssClass="icon-monospaced" image="expand" markupView="lexicon" />
				</button>

				<button class="btn btn-default btn-xs hide lfr-portal-tooltip" data-title="<%= LanguageUtil.get(resourceBundle, "dark-theme") %>" id="<%= HtmlUtil.escapeAttribute(name) %>SwitchTheme" type="button">
					<aui:icon cssClass="icon-monospaced" image="moon" markupView="lexicon" />
				</button>

				<button class="btn btn-default btn-xs editor-view lfr-portal-tooltip" data-title="<%= LanguageUtil.get(resourceBundle, "code-view") %>" id="<%= HtmlUtil.escapeAttribute(name) %>Switch" type="button">
					<aui:icon cssClass="icon-monospaced" image="code" markupView="lexicon" />
				</button>
			</div>
		</c:when>
		<c:otherwise>
			<%= alloyEditor %>
		</c:otherwise>
	</c:choose>
</liferay-util:buffer>

<div class="alloy-editor-container" id="<%= HtmlUtil.escapeAttribute(name) %>Container">
	<c:if test="<%= autoCreate %>">
		<%= editor %>
	</c:if>
</div>

<%
String modules = "liferay-alloy-editor";

String uploadURL = StringPool.BLANK;

if (editorOptions != null) {
	uploadURL = editorOptions.getUploadURL();

	if (Validator.isNotNull(data) && Validator.isNotNull(uploadURL)) {
		modules += ",liferay-editor-image-uploader";
	}
}

if (showSource) {
	modules += ",liferay-alloy-editor-source";
}

name = HtmlUtil.escapeJS(name);
%>

<aui:script use="<%= modules %>">

	<%
	Locale contentsLocale = LocaleUtil.fromLanguageId(contentsLanguageId);

	contentsLanguageId = LocaleUtil.toLanguageId(contentsLocale);
	%>

	var alloyEditor;

	var getInitialContent = function() {
		var data;

		if (window['<%= HtmlUtil.escapeJS(namespace + initMethod) %>']) {
			data = <%= HtmlUtil.escapeJS(namespace + initMethod) %>();
		}
		else {
			data = '<%= (contents != null) ? HtmlUtil.escapeJS(contents) : StringPool.BLANK %>';
		}

		return data;
	};

	var createInstance = function() {
		document.getElementById('<%= name %>').setAttribute('contenteditable', true);

		var editorConfig = <%= Validator.isNotNull(editorConfigJSONObject) %> ? <%= editorConfigJSONObject %> : {};

		if (editorConfig.extraPlugins) {
			editorConfig.extraPlugins = A.Array.filter(
				editorConfig.extraPlugins.split(','),
				function(item) {
					return item !== 'ae_embed';
				}
			).join(',');
		}

		editorConfig.removePlugins = editorConfig.removePlugins ? editorConfig.removePlugins + ',ae_embed' : 'ae_embed';

		editorConfig = A.merge(
			{
				title: false
			},
			editorConfig
		);

		var plugins = [];

		<c:if test="<%= Validator.isNotNull(data) && Validator.isNotNull(uploadURL) %>">
			plugins.push(
				{
					cfg: {
						uploadItemReturnType: '<%= editorOptions.getUploadItemReturnType() %>',
						uploadUrl: '<%= uploadURL %>'
					},
					fn: A.Plugin.LiferayEditorImageUploader
				}
			);
		</c:if>

		<c:if test="<%= showSource %>">
			plugins.push(A.Plugin.LiferayAlloyEditorSource);
		</c:if>

		alloyEditor = new A.LiferayAlloyEditor(
			{
				contents: '<%= HtmlUtil.escapeJS(contents) %>',
				editorConfig: editorConfig,
				namespace: '<%= name %>',

				<c:if test="<%= Validator.isNotNull(onBlurMethod) %>">
					onBlurMethod: '<%= HtmlUtil.escapeJS(namespace + onBlurMethod) %>',
				</c:if>

				<c:if test="<%= Validator.isNotNull(onChangeMethod) %>">
					onChangeMethod: '<%= HtmlUtil.escapeJS(namespace + onChangeMethod) %>',
				</c:if>

				<c:if test="<%= Validator.isNotNull(onFocusMethod) %>">
					onFocusMethod: '<%= HtmlUtil.escapeJS(namespace + onFocusMethod) %>',
				</c:if>

				<c:if test="<%= Validator.isNotNull(onInitMethod) %>">
					onInitMethod: '<%= HtmlUtil.escapeJS(namespace + onInitMethod) %>',
				</c:if>

				plugins: plugins,
				textMode: <%= (editorOptions != null) ? editorOptions.isTextMode() : Boolean.FALSE.toString() %>,

				<%
				boolean useCustomDataProcessor = (editorOptionsDynamicAttributes != null) && GetterUtil.getBoolean(editorOptionsDynamicAttributes.get("useCustomDataProcessor"));
				%>

				useCustomDataProcessor: <%= useCustomDataProcessor %>
			}
		).render();

		<liferay-util:dynamic-include key='<%= "com.liferay.frontend.editor.alloyeditor.web#" + editorName + "#onEditorCreate" %>' />
	};

	window['<%= name %>'] = {
		create: function() {
			if (!alloyEditor) {
				var editorNode = A.Node.create('<%= HtmlUtil.escapeJS(editor) %>');

				var editorContainer = A.one('#<%= name %>Container');

				editorContainer.appendChild(editorNode);

				window['<%= name %>'].initEditor();
			}
		},

		destroy: function() {
			window['<%= name %>'].dispose();

			window['<%= name %>'] = null;
		},

		dispose: function() {
			if (alloyEditor) {
				alloyEditor.destroy();

				alloyEditor = null;
			}

			var editorNode = document.getElementById('<%= name %>');

			if (editorNode) {
				editorNode.parentNode.removeChild(editorNode);
			}
		},

		focus: function() {
			if (alloyEditor) {
				alloyEditor.focus();
			}
		},

		getHTML: function() {
			var data = '';

			if (alloyEditor && alloyEditor.instanceReady) {
				data = alloyEditor.getHTML();
			}
			else {
				data = getInitialContent();
			}

			return data;
		},

		getNativeEditor: function() {
			var nativeEditor;

			if (alloyEditor) {
				nativeEditor = alloyEditor.getEditor();
			}

			return nativeEditor;
		},

		getText: function() {
			var data = '';

			if (alloyEditor && alloyEditor.instanceReady) {
				data = alloyEditor.getText();
			}
			else {
				data = getInitialContent();
			}

			return data;
		},

		initEditor: function() {
			createInstance();
		},

		instanceReady: false,

		setHTML: function(value) {
			if (alloyEditor) {
				alloyEditor.setHTML(value);
			}
		}
	};

	Liferay.fire(
		'editorAPIReady',
		{
			editor: window['<%= name %>'],
			editorName: '<%= name %>'
		}
	);

	<c:if test="<%= autoCreate %>">
		window['<%= name %>'].initEditor();
	</c:if>

	var destroyInstance = function(event) {
		if (event.portletId === '<%= portletId %>') {
			try {
				window['<%= name %>'].destroy();
			}
			catch (e) {
			}

			Liferay.detach('destroyPortlet', destroyInstance);
		}
	};

	Liferay.on('destroyPortlet', destroyInstance);
</aui:script>