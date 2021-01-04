function  roiMovedCallback(rectangle,evt)
% This runs when a box's rectangle is resized
    hObject = get(rectangle,'Parent');
    handles = guidata(hObject);
    tag = get(rectangle,'Tag');
    
    i = find(handles.data.calls.Tag == str2double(tag), 1);
    if ~isempty(i)
        handles.data.calls{i,'Box'} = rectangle.Position;
        handles.data.calls{i,'RelBox'} = calculateRelativeBox(rectangle.Position, handles.axes1);         

        audio_start = handles.data.audiodata.SampleRate*rectangle.Position(1);
        audio_stop = handles.data.audiodata.SampleRate*(rectangle.Position(1) +1*rectangle.Position(3));

        audio_start = max(audio_start,1);
        audio_stop = min(audio_stop,size(handles.data.audiodata.samples,1));
        audio = handles.data.audiodata.samples(round(audio_start):round(audio_stop));
        audio = audio - mean(audio,1);
        handles.data.calls{i, 'Audio'} = {int16(audio*32767)};            
    end
    
%     delete(rectangle)
    guidata(hObject,handles);
%     handles = guidata(hObject);    
    SortCalls(hObject, [], handles, 'time', 0, str2double(tag));
%     guidata(hObject,handles);
%     update_fig(hObject, [], handles)
end

