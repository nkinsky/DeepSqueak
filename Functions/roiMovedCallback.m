function  roiMovedCallback(rectangle,evt)
% This runs when a box's rectangle is resized
    hObject = get(rectangle,'Parent');
    handles = guidata(hObject);
    tag = get(rectangle,'Tag');
    
    i = find(handles.data.calls.Tag == str2double(tag), 1);
    if ~isempty(i)
        handles.data.calls{i,'Box'} = rectangle.Position;       
    end
    
%     delete(rectangle)
    guidata(hObject,handles);
%     handles = guidata(hObject);    
    SortCalls(hObject, [], handles, 'time', 0, str2double(tag));
%     guidata(hObject,handles);
%     update_fig(hObject, [], handles)
end

