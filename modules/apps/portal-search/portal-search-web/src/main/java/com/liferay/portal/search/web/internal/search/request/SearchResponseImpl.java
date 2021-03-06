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

package com.liferay.portal.search.web.internal.search.request;

import com.liferay.portal.kernel.dao.search.SearchContainer;
import com.liferay.portal.kernel.search.Document;
import com.liferay.portal.kernel.search.Hits;
import com.liferay.portal.kernel.search.SearchContext;
import com.liferay.portal.kernel.search.facet.Facet;
import com.liferay.portal.search.web.internal.util.SearchStringUtil;
import com.liferay.portal.search.web.search.request.SearchResponse;
import com.liferay.portal.search.web.search.request.SearchSettings;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * @author Rodrigo Paulino
 * @author André de Oliveira
 */
public class SearchResponseImpl implements SearchResponse {

	@Override
	public List<Document> getDocuments() {
		return _documents;
	}

	@Override
	public Facet getFacet(String name) {
		Map<String, Facet> facets = _searchContext.getFacets();

		return facets.get(name);
	}

	/**
	 * @deprecated As of 1.3.0
	 */
	@Deprecated
	@Override
	public String[] getHighlights() {
		return null;
	}

	public Hits getHits() {
		return _hits;
	}

	@Override
	public Optional<String> getKeywordsOptional() {
		return Optional.ofNullable(_keywords);
	}

	@Override
	public int getPaginationDelta() {
		return _paginationDelta;
	}

	@Override
	public int getPaginationStart() {
		return _paginationStart;
	}

	@Override
	public String getQueryString() {
		return _queryString;
	}

	@Override
	public List<String> getRelatedQueriesSuggestions() {
		return Arrays.asList(_hits.getQuerySuggestions());
	}

	public SearchContainer<Document> getSearchContainer() {
		return _searchContainer;
	}

	public SearchContext getSearchContext() {
		return _searchContext;
	}

	@Override
	public SearchSettings getSearchSettings() {
		return _searchSettings;
	}

	@Override
	public Optional<String> getSpellCheckSuggestionOptional() {
		return SearchStringUtil.maybe(_hits.getCollatedSpellCheckResult());
	}

	@Override
	public int getTotalHits() {
		return _totalHits;
	}

	public void setDocuments(List<Document> documents) {
		_documents = documents;
	}

	public void setHits(Hits hits) {
		_hits = hits;
	}

	public void setKeywords(String keywords) {
		_keywords = keywords;
	}

	public void setPaginationDelta(int paginationDelta) {
		_paginationDelta = paginationDelta;
	}

	public void setPaginationStart(int paginationStart) {
		_paginationStart = paginationStart;
	}

	public void setQueryString(String queryString) {
		_queryString = queryString;
	}

	public void setSearchContainer(SearchContainer<Document> searchContainer) {
		_searchContainer = searchContainer;
	}

	public void setSearchContext(SearchContext searchContext) {
		_searchContext = searchContext;
	}

	public void setSearchSettings(SearchSettings searchSettings) {
		_searchSettings = searchSettings;
	}

	public void setTotalHits(int totalHits) {
		_totalHits = totalHits;
	}

	private List<Document> _documents;
	private Hits _hits;
	private String _keywords;
	private int _paginationDelta;
	private int _paginationStart;
	private String _queryString;
	private SearchContainer<Document> _searchContainer;
	private SearchContext _searchContext;
	private SearchSettings _searchSettings;
	private int _totalHits;

}