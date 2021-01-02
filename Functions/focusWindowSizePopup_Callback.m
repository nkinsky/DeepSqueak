function focusWindowSizePopup_Callback(hObject, eventdata, handles)
    hObject = handles.focusWindowSizePopup;
    dropdown_items = cellstr(get(hObject,'String')); 
    focus_seconds = regexp(dropdown_items{get(hObject,'Value')},'([\d*.])*','match');
    focus_seconds = str2num(focus_seconds{1});
    handles.data.settings.focus_window_size = focus_seconds;
    handles.data.saveSettings();
    %set(handles.slider1,  'SliderStep', [seconds/handles.data.audiodata.duration, 0.1]);
    update_fig(hObject, eventdata, handles);
    guidata(hObject, handles);
    
end