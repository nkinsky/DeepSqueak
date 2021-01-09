% --- Executes on button press in LOAD CALLS.
function loadcalls_Callback(hObject, eventdata, handles,call_file_number)
h = waitbar(0,'Loading Calls Please wait...');
update_folders(hObject, eventdata, handles);
handles = guidata(hObject);
if nargin == 3 % if "Load Calls" button pressed
    handles.current_file_id = get(handles.popupmenuDetectionFiles,'Value');
    handles.current_detection_file = handles.detectionfiles(handles.current_file_id).name;
end

handles.data.calls = [];
handles.data.audiodata = [];
[handles.data.calls, handles.data.audiodata] = loadCallfile(fullfile(handles.detectionfiles(handles.current_file_id).folder,  handles.current_detection_file), handles);

% Position of the focus window to the first call in the file
handles.data.focusCenter = handles.data.calls.Box(handles.data.currentcall,1) + handles.data.calls.Box(handles.data.currentcall,3)/2;

initialize_display(hObject, eventdata, handles);
close(h);
