function  render_call_position(hObject,handles, all_calls)
%% This function makes and updates the little window with the green lines

% Timestamp for each call
CallTime = handles.data.calls.Box(:,1);

% Initialize the display
if all_calls
    line([0 max(CallTime)],[0 0],'LineWidth',1,'Color','w','Parent', handles.detectionAxes);
    line([0 max(CallTime)],[1 1],'LineWidth',1,'Color','w','Parent', handles.detectionAxes);
    set(handles.detectionAxes,'XLim',[0 handles.data.audiodata.Duration]);
    set(handles.detectionAxes,'YLim',[0 1]);
    
    set(handles.detectionAxes,'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','on','Clim',[0 1]);
    set(handles.detectionAxes,'YTickLabel',[]);
    
    set(handles.detectionAxes,'YTick',[]);
    set(handles.detectionAxes,'XTick',[]);
    %set(handles.detectionAxes,'XColor','none');
    
    guidata(hObject, handles);
    handles = guidata(hObject);
    
    cla(handles.detectionAxes);
    
    screen_size = get(0,'screensize');
    min_call_render_difference = 2*handles.data.audiodata.Duration / (screen_size(3));
    for i=1:length(CallTime)
        color = [0,1,0];
        
        if i +1 < length(CallTime)
            if  CallTime(i+1) - CallTime(i) < min_call_render_difference
                continue
            end
        end
        
        if ~handles.data.calls.Accept(i)
            color = [1,0,0];
        end
        
        line([CallTime(i) CallTime(i)], [0,1],'Parent', handles.detectionAxes,'Color',color, 'PickableParts','none') ;
    end
    
    % Initialize the timestamp text and current call line
    handles.CurrentCallLineText = text(0, 20, ' ', 'Color', 'W', 'HorizontalAlignment', 'center', 'Parent', handles.detectionAxes);
    handles.CurrentCallLinePosition = line([0,0],[0 1],'LineWidth',3,'Color','g','Parent', handles.detectionAxes,'PickableParts','none');
    handles.CurrentCallWindowRectangle = rectangle('Position',[0 0 1 1], 'Parent',handles.detectionAxes,'LineWidth',1,'EdgeColor',[1 1 1 1],'FaceColor',[1 1 1 .15]);
    
end




if isfield(handles, 'data')
    
    calltime = handles.data.calls.Box(handles.data.currentcall, 1);
    
    if handles.data.calls.Accept(handles.data.currentcall)
        handles.CurrentCallLinePosition.Color = [0,1,0];
    else
        handles.CurrentCallLinePosition.Color = [1,0,0];
    end
    
    sec = mod(calltime, 60);
    min = floor(calltime / 60);
    set(handles.CurrentCallLineText,'Position',[calltime,1.4,0],'String',sprintf('%.0f:%.2f', min, sec));
    set(handles.CurrentCallLinePosition,'XData',[calltime(1) calltime(1)]);

    handles.CurrentCallWindowRectangle.Position = [  handles.data.windowposition 0 handles.data.settings.windowSize  1];
end

guidata(hObject,handles);
end

