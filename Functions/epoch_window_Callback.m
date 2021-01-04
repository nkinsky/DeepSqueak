function epoch_window_Callback(hObject, eventdata, handles)
    
    handles = guidata(hObject);
    padding_value_index = get(handles.focusWindowSizePopup,'Value');
    padding_values =  get(handles.focusWindowSizePopup,'String');
    seconds = regexp(padding_values{padding_value_index},'([\d*.])*','match');
    seconds = str2num(seconds{1});

    click_position = eventdata.IntersectionPoint;
    
    window_min = click_position(1) - seconds/2;
    window_max = click_position(1) + seconds/2;    
    
    handles.current_focus_position = [window_min 0 seconds 0 ];
    handles.data.focusCenter = click_position(1);
    
    %% Find the call closest to the click and make it the current call
%     calls_within_window = find(...
%         handles.data.calls.Box(:,1) > handles.data.windowposition &...
%         sum(handles.data.calls.Box(:,[1,3]),2) < handles.data.windowposition + handles.data.settings.windowSize);
    
        callMidpoints = handles.data.calls.Box(:,1) + handles.data.calls.Box(:,3)/2;
        [~, closestCall] = min(abs(callMidpoints - handles.data.focusCenter));
        handles.data.currentcall = closestCall;
%         handles.data.current_call_valid = true;
        handles.data.current_call_tag = num2str(handles.data.calls{handles.data.currentcall,'Tag'});
%     end
    update_fig(hObject, eventdata, handles);
    guidata(hObject, handles);
    
    
end

