function update_fig(hObject, eventdata, handles, force_render_page)
if nargin < 4
    force_render_page = false;
end

set(handles.hFig, 'pointer', 'watch')
% drawnow nocallbacks

if isempty(handles.data.calls)
    return
end

%% Update focus position
handles.current_focus_position = [
    handles.data.focusCenter - handles.data.settings.focus_window_size ./ 2
    0
    handles.data.settings.focus_window_size
    0];
guidata(hObject, handles);


%% Update the position of the page window by using focus position
jumps = floor(handles.data.focusCenter / handles.data.settings.pageSize);
handles.data.windowposition = jumps*handles.data.settings.pageSize;


%% Plot Call Position (updates the little bar with the green lines)
handles = render_call_position(handles,handles.update_position_axes);
% handles = guidata(hObject);



%% Render the page view if the page changed
if handles.data.lastWindowPosition ~= handles.data.windowposition || force_render_page
    renderEpochSpectogram(hObject,handles);
    handles = guidata(hObject);
end

% set(0,'defaultFigureVisible','off');
% if  ~isempty(handles.current_focus_position) || handles.data.current_call_valid
handles = update_focus_display(handles);
% end

%% Plot the boxes on top of the detections
handles = render_call_boxes(handles.spectogramWindow, handles,false,false);
handles = render_call_boxes(handles.axes1, handles, true,false);


%% Position of the gray box in the page view
spectogram_axes_ylim = ylim(handles.spectogramWindow);
handles.currentWindowRectangle.Position = [
    handles.current_focus_position(1)
    spectogram_axes_ylim(1)
    handles.current_focus_position(3)
    spectogram_axes_ylim(2)
    ];


% set(groot,'defaultFigureVisible','on');
set(handles.hFig, 'pointer', 'arrow')
guidata(hObject, handles);


