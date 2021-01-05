function  epochWindowSizePopup_Callback(hObject, eventdata, handles)

% hObject = handles.epochWindowSizePopup;
dropdown_items = cellstr(get(hObject,'String')); 
page_seconds = regexp(dropdown_items{get(hObject,'Value')},'([\d*.])*','match');
page_seconds = str2double(page_seconds{1});
handles.data.settings.pageSize = page_seconds;
handles.data.saveSettings();

update_fig(hObject, eventdata, handles, true);

guidata(hObject, handles);
end

