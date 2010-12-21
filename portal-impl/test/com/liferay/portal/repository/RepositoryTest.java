/**
 * Copyright (c) 2000-2010 Liferay, Inc. All rights reserved.
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

package com.liferay.portal.repository;

import com.liferay.portal.kernel.io.unsync.UnsyncByteArrayInputStream;
import com.liferay.portal.kernel.repository.LocalRepository;
import com.liferay.portal.kernel.repository.RepositoryConstants;
import com.liferay.portal.kernel.repository.RepositoryFactoryUtil;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.repository.model.Folder;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.UnicodeProperties;
import com.liferay.portal.model.Layout;
import com.liferay.portal.service.LayoutLocalServiceUtil;
import com.liferay.portal.service.ServiceContext;
import com.liferay.portal.util.PortletKeys;
import com.liferay.portal.util.TestPropsValues;
import com.liferay.portlet.documentlibrary.model.DLFolder;
import com.liferay.portlet.documentlibrary.model.DLFolderConstants;
import com.liferay.portlet.documentlibrary.service.DLRepositoryLocalServiceUtil;

import java.io.InputStream;

import junit.framework.TestCase;

/**
 * @author Alexander Chow
 */
public class RepositoryTest extends TestCase {

	public void testBasic() throws Exception {
		long[] repositoryIds = new long[2];

		// Create repositories

		repositoryIds[0] = RepositoryFactoryUtil.createRepository(
			getGroupId(), "Test 1", "Test 1", PortletKeys.DOCUMENT_LIBRARY,
			RepositoryConstants.TYPE_LIFERAY, new UnicodeProperties());

		repositoryIds[1] = RepositoryFactoryUtil.createRepository(
			getGroupId(), "Test 2", "Test 2", PortletKeys.DOCUMENT_LIBRARY,
			RepositoryConstants.TYPE_LIFERAY, new UnicodeProperties());

		// Delete repositories

		RepositoryFactoryUtil.deleteRepositories(
			getGroupId(), RepositoryConstants.PURGE_ALL);

		for (int i = 0; i < repositoryIds.length; i++) {
			long repositoryId = repositoryIds[i];

			try {
				RepositoryFactoryUtil.getLocalRepository(repositoryId);

				fail("Should not be able to access repository " + repositoryId);
			}
			catch (Exception e) {
			}
		}
	}

	public void testCreateAndDeleteFileEntries() throws Exception {

		// One default and one mapped repository

		long defaultRepositoryId = getGroupId();

		long dlRepositoryId = RepositoryFactoryUtil.createRepository(
			getGroupId(), "Test", "Test", PortletKeys.DOCUMENT_LIBRARY,
			RepositoryConstants.TYPE_LIFERAY, new UnicodeProperties());

		long[] repositoryIds = {defaultRepositoryId, dlRepositoryId};

		long[] fileEntryIds = new long[4];

		long[] folderIds = new long[2];

		InputStream inputStream = new UnsyncByteArrayInputStream(
			_TEST_CONTENT.getBytes());

		// Add folders and files

		for (int i = 0; i < repositoryIds.length; i++) {
			long repositoryId = repositoryIds[i];

			LocalRepository localRepository =
				RepositoryFactoryUtil.getLocalRepository(repositoryId);

			FileEntry fileEntry1 = localRepository.addFileEntry(
				TestPropsValues.USER_ID,
				DLFolderConstants.DEFAULT_PARENT_FOLDER_ID,
				String.valueOf(DLFolderConstants.DEFAULT_PARENT_FOLDER_ID),
				StringPool.BLANK, StringPool.BLANK, null, inputStream,
				_TEST_CONTENT.length(), new ServiceContext());

			fileEntryIds[i] = fileEntry1.getFileEntryId();

			Folder folder = localRepository.addFolder(
				TestPropsValues.USER_ID,
				DLFolderConstants.DEFAULT_PARENT_FOLDER_ID,
				String.valueOf(repositoryId), String.valueOf(repositoryId),
				new ServiceContext());

			folderIds[i] = folder.getFolderId();

			FileEntry fileEntry2 = localRepository.addFileEntry(
				TestPropsValues.USER_ID, folderIds[i],
				String.valueOf(folderIds[i]), StringPool.BLANK,
				StringPool.BLANK, null, inputStream, _TEST_CONTENT.length(),
				new ServiceContext());

			fileEntryIds[i + 2] = fileEntry2.getFileEntryId();
		}

		// Verify mapped folder

		DLFolder folder = DLRepositoryLocalServiceUtil.getFolder(folderIds[1]);
		DLFolder repositoryFolder = folder.getParentFolder();

		assertEquals(
			"Parent folder of mapped repository must be " +
				DLFolderConstants.MAPPED_PARENT_FOLDER_ID,
			repositoryFolder.getParentFolderId(),
			DLFolderConstants.MAPPED_PARENT_FOLDER_ID);

		// Delete repositories

		RepositoryFactoryUtil.deleteRepositories(
			getGroupId(), RepositoryConstants.PURGE_ALL);

		for (int i = 0; i < repositoryIds.length; i++) {
			long repositoryId = repositoryIds[i];

			long fileEntryId = fileEntryIds[i];

			try {
				LocalRepository localRepository =
					RepositoryFactoryUtil.getLocalRepository(repositoryId);

				localRepository.getFileEntry(fileEntryId);

				fail(
					"Should not be able to get file entry " + fileEntryId +
						" from repository " + repositoryId);
			}
			catch (Exception e) {
			}
		}
	}

	protected static long getGroupId() throws Exception {
		if (_groupId == 0) {
			Layout layout = LayoutLocalServiceUtil.getLayout(
				TestPropsValues.LAYOUT_PLID);

			_groupId = layout.getGroupId();
		}

		return _groupId;
	}

	private static final String _TEST_CONTENT =
		"LIFERAY\nEnterprise. Open Source. For Life.";

	private static long _groupId;

}