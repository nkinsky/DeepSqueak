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

tag_column_exists = strcmp('Tag',handles.data.calls.Properties.VariableNames);
if  ~tag_column_exists
    handles.data.calls.Tag =  [1:size(handles.data.calls,1)]';
end

initialize_display(hObject, eventdata, handles);
close(h);
