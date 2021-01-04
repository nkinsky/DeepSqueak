function initialize_display(hObject, eventdata, handles)

% Remove anything currently in the axes
cla(handles.axes7);
cla(handles.detectionAxes);
cla(handles.axes1);
cla(handles.spectogramWindow);
%cla(handles.axes4);
cla(handles.axes3);

%
handles.data.currentcall = 1;
handles.data.current_call_tag = 1;
handles.data.current_call_valid = true;

handles.data.windowposition = 0;
handles.data.lastWindowPosition = -1;
handles.update_position_axes = 0;

% Position of the focus window
handles.data.focusCenter = handles.data.calls.Box(handles.data.currentcall,1) + handles.data.calls.Box(handles.data.currentcall,3)/2;
    

%% Create plots for update_fig to update

% Waveform
handles.Waveform = line(handles.axes3,1,1,'Color',[.1 .3 .3]);
handles.SNR = surface(handles.axes3,[],[],[],[],...
    'facecol','r',...
    'edgecol','interp',...
    'linew',2);
set(handles.axes3,'YTickLabel',[]);
set(handles.axes3,'XTickLabel',[]);
set(handles.axes3,'XTick',[]);
set(handles.axes3,'YTick',[]);
set(handles.axes3,'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off','Ylim',[-1 0],'Clim',[0 1]);

% Contour
handles.ContourScatter = scatter(1:5,1:5,'LineWidth',1.5,'Parent',handles.axes7,'XDataSource','x','YDataSource','y');
set(handles.axes7,'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off');
set(handles.axes7,'YTickLabel',[]);
set(handles.axes7,'XTickLabel',[]);
set(handles.axes7,'XTick',[]);
set(handles.axes7,'YTick',[]);
handles.ContourLine = line(handles.axes7,[1,5],[1,5],'LineStyle','--','Color','y');

% Focus spectogram
handles.spect = imagesc([],[],handles.background,'Parent', handles.axes1);
cb=colorbar(handles.axes1);
cb.Label.String = 'Amplitude';
cb.Color = [1 1 1];
cb.FontSize = 12;
ylabel(handles.axes1,'Frequency (kHz)','Color','w');
%xlabel(handles.axes1,'Time (s)','Color','w');
set(handles.axes1,'Color',[.1 .1 .1]);
handles.box=rectangle('Position',[1 1 1 1],'Curvature',0.2,'EdgeColor','g',...
    'LineWidth',3,'Parent', handles.axes1);

% Epoch spectogram
handles.epochSpect = imagesc([],[],handles.background,'Parent', handles.spectogramWindow);
cb=colorbar(handles.spectogramWindow);
cb.Label.String = 'Amplitude';
cb.Color = [1 1 1];
cb.FontSize = 12;
ylabel(handles.spectogramWindow,'Frequency (kHz)','Color','w');
xlabel(handles.spectogramWindow,'Time (s)','Color','w');
set(handles.spectogramWindow,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1],'Clim',[0 get_spectogram_max(hObject,handles)]);
set(handles.spectogramWindow,'Color',[.1 .1 .1]);
set(handles.spectogramWindow,'Visible', 'on');
set(handles.epochSpect,'Visible', 'on');
set(handles.epochSpect,'ButtonDownFcn',@epoch_window_Callback);

%Make the top scroll button visible
set(handles.topRightButton, 'Visible', 'on');
set(handles.topLeftButton, 'Visible', 'on');

% Plot Call Position
render_call_position(hObject,handles,true);
handles = guidata(hObject);

handles.PageWindowRectangles = {};
handles.FocusWindowRectangles = {};

colormap(handles.axes1,handles.data.cmap);
colormap(handles.spectogramWindow,handles.data.cmap);

callPositionAxesXLim = xlim(handles.detectionAxes);
callPositionAxesXLim(1) = 0;
callPositionAxesXLim(2) = handles.data.audiodata.Duration;
xlim(handles.detectionAxes,callPositionAxesXLim);

% Rectangle that shows the current position in the spectrogram
handles.currentWindowRectangle = rectangle(handles.spectogramWindow,...
    'Position',[0,0,0,0],...
    'FaceColor', [1, 1, 1, 0.15],...
    'EdgeColor', [1, 1, 1, 1], 'LineWidth',1.5,...
    'LineStyle','--',...
    'PickableParts', 'none');

update_fig(hObject, eventdata, handles);
guidata(hObject,handles);

