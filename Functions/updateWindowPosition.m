function windowposition = updateWindowPosition(handles)

current_call_start = handles.data.calls.Box(handles.data.currentcall,1);

if handles.data.windowposition  + handles.data.settings.windowSize < current_call_start || handles.data.windowposition  + handles.data.settings.windowSize > current_call_start
    jumps = floor(current_call_start / handles.data.settings.windowSize);
    windowposition = jumps*handles.data.settings.windowSize;
end
end