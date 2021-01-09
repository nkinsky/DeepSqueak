function epoch_window_Callback(hObject, eventdata)

handles = guidata(hObject);
handles.data.focusCenter = eventdata.IntersectionPoint(1);
handles.data.focusCenter = max(handles.data.focusCenter,  handles.data.settings.focus_window_size/2);
handles.data.focusCenter = min(handles.data.focusCenter,  handles.data.audiodata.Duration - handles.data.settings.focus_window_size/2);

%% Find the call closest to the click and make it the current call
callMidpoints = handles.data.calls.Box(:,1) + handles.data.calls.Box(:,3)/2;
[~, closestCall] = min(abs(callMidpoints - handles.data.focusCenter));
handles.data.currentcall = closestCall;
update_fig(hObject, eventdata, handles);

end

