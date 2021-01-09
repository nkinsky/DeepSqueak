function  mousePositionSelection_Callback(hObject,eventdata, handles)
% This fuction runs when the little bar with the green lines is clicked

%  handles.data.focusCenter = eventdata.IntersectionPoint(1);
%  handles.data.focusCenter = max(handles.data.focusCenter,  handles.data.settings.focus_window_size);

% epoch_window_Callback runs guidata and update_fig so we don't need that here
guidata(hObject, handles);  
epoch_window_Callback(hObject, eventdata)
end

