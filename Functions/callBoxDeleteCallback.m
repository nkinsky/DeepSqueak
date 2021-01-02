function callBoxDeleteCallback(rectangle,evt)

% Only do anything if the face was selected, not the markers
if ~strcmp(evt.SelectedPart, 'face')
    return
end

hObject = get(rectangle,'Parent');
handles = guidata(hObject);
clicked_tag = str2double(get(rectangle, 'Tag'));

switch  evt.SelectionType
    case 'right' % delete if right click
        currentcall = find(handles.data.calls.Tag == clicked_tag);
        handles.data.calls(currentcall,:) = [];
        SortCalls(hObject, [], handles, 'time', 0, currentcall - 1);
        rectangle.Visible = 'off';
    case 'left' % Make it the current call if left clicked
        if clicked_tag ~= handles.data.currentcall
            handles.data.currentcall = clicked_tag;
            handles.data.current_call_tag = num2str(clicked_tag);
            update_fig(hObject, [], handles)
        end
    case 'ctrl'
        choosedialog(rectangle,handles);
end
guidata(hObject, handles);
end

function choice = choosedialog(rectangle,handles)

figure = handles.figure1;
hObject = get(rectangle,'Parent');
axes_position = get(hObject, 'Position');

axes_x_lim = xlim(hObject);
axes_y_lim = ylim(hObject);
position = get(rectangle, 'Position');
tag = get(rectangle, 'Tag');

dialog_width = 354;
dialog_heigth = 154;

rect_x_relative_to_axes = (position(1)-axes_x_lim(1) + position(3)) / (axes_x_lim(2)-axes_x_lim(1));
rect_y_relative_to_axes = (position(2) + position(4)) / (axes_y_lim(2)-axes_y_lim(1));

set(figure,'Units','Pixels');
fig_pos = get(figure, 'Position');

x_position = (axes_position(1) + axes_position(3)*rect_x_relative_to_axes)*fig_pos(3);
y_position = (axes_position(2) + axes_position(4)*rect_y_relative_to_axes)*fig_pos(4) - dialog_heigth;

%Make sure the dialog stays within the figure
x_position = min(x_position,fig_pos(3)-dialog_width);
y_position = min(y_position,fig_pos(4)-dialog_heigth);

d = dialog('Position',[x_position y_position dialog_width dialog_heigth],'Name',['Call ' tag],'Units','normal');

n_columns = 5;
n_rows = 6;
button_width = 70;
button_height = 25;
button_spacing = 1;
type_index = 1;
padding = 1;
for c=1:n_columns
    for r=1:n_rows
        x_position = padding + (c-1)*button_width + button_spacing*(c-1);
        y_position = padding + (r-1)*button_height + button_spacing*(r-1);
        
        label = uicontrol('Parent',d,...
            'Position',[x_position y_position button_width button_height],...
            'String',handles.data.settings.labels{type_index},...
            'Callback',{@label_callback,handles.data.settings.labels{type_index}},...
            'BackgroundColor',[0.302,0.502,0.302],...
            'ForegroundColor',[1.0 1.0 1.0]);
        type_index = type_index +1;
    end
end

uiwait(d);



    function label_callback(hObject,event,new_type)
        i = find(handles.data.calls.Tag == str2double(tag), 1);
        if ~isempty(i)
            handles.data.calls{i,'Type'} = {new_type};
            guidata(figure,handles);
            handles = guidata(figure);
            guidata(figure,handles);
            delete(gcf);
            update_fig(figure, [], handles);
        end
    end

end