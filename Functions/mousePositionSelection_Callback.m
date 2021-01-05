function  mousePositionSelection_Callback(hObject,eventdata, handles)
% This fuction runs when the little bar with the green lines is clicked

click_position = eventdata.IntersectionPoint;
% window_min = click_position(1) - handles.data.settings.focus_window_size/2;

% handles.current_focus_position =  [window_min, 0, handles.data.settings.focus_window_size,0];
handles.data.windowposition =  click_position(1) - handles.data.settings.pageSize/2;
handles.data.windowposition =  min(handles.data.windowposition,handles.data.audiodata.Duration - handles.data.settings.pageSize/2);
handles.data.windowposition =  max(handles.data.windowposition,handles.data.settings.pageSize/2);
% epoch_window_Callback runs guidata and update_fig so we don't need that here
guidata(hObject, handles);  
epoch_window_Callback(hObject, eventdata)
end

