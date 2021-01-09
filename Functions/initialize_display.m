function initialize_display(hObject, eventdata, handles)

% Remove anything currently in the axes
cla(handles.contourWindow);
cla(handles.detectionAxes);
cla(handles.focusWindow);
cla(handles.spectogramWindow);
cla(handles.waveformWindow);

%
handles.data.currentcall = 1;
handles.data.current_call_valid = true;

handles.data.windowposition = 0;
handles.data.lastWindowPosition = -1;
handles.update_position_axes = 1;
    

%% Create plots for update_fig to update

% Waveform
handles.Waveform = line(handles.waveformWindow,1,1,'Color',[.1 .3 .3]);
handles.SNR = surface(handles.waveformWindow,[],[],[],[],...
    'facecol','r',...
    'edgecol','interp',...
    'linew',2);
set(handles.waveformWindow,...
    'YTickLabel',[],...
    'XTickLabel',[],...
    'XTick',[],...
    'YTick',[],...
    'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],...
    'Box','off',...
    'Ylim',[-1 0],...
    'Clim',[0 1],...
    'Colormap', parula);

% Contour
handles.ContourScatter = scatter(1:5,1:5,'LineWidth',1.5,'Parent',handles.contourWindow,'XDataSource','x','YDataSource','y');
set(handles.contourWindow,'Color',[.1 .1 .1],'YColor',[1 1 1],'XColor',[1 1 1],'Box','off');
set(handles.contourWindow,'YTickLabel',[]);
set(handles.contourWindow,'XTickLabel',[]);
set(handles.contourWindow,'XTick',[]);
set(handles.contourWindow,'YTick',[]);
handles.ContourLine = line(handles.contourWindow,[1,5],[1,5],'LineStyle','--','Color','y');

% Focus spectogram
handles.spect = imagesc([],[],handles.background,'Parent', handles.focusWindow);
cb=colorbar(handles.focusWindow);
cb.Label.String = 'Amplitude';
cb.Color = [1 1 1];
cb.FontSize = 12;
ylabel(handles.focusWindow,'Frequency (kHz)','Color','w');
%xlabel(handles.focusWindow,'Time (s)','Color','w');
set(handles.focusWindow,'Color',[.1 .1 .1]);
handles.box=rectangle('Position',[1 1 1 1],'Curvature',0.2,'EdgeColor','g',...
    'LineWidth',3,'Parent', handles.focusWindow);

% Epoch spectogram
handles.epochSpect = imagesc([],[],handles.background,'Parent', handles.spectogramWindow);
cb=colorbar(handles.spectogramWindow);
cb.Label.String = 'Amplitude';
cb.Color = [1 1 1];
cb.FontSize = 12;
ylabel(handles.spectogramWindow,'Frequency (kHz)','Color','w');
xlabel(handles.spectogramWindow,'Time (s)','Color','w');
set(handles.spectogramWindow,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1],'Clim',[0 1]);
set(handles.spectogramWindow,'Color',[.1 .1 .1]);
set(handles.spectogramWindow,'Visible', 'on');
set(handles.epochSpect,'Visible', 'on');
set(handles.epochSpect,'ButtonDownFcn', @(hObject,eventdata) mousePositionSelection_Callback(hObject,eventdata,guidata(hObject)));


%Make the top scroll button visible
set(handles.topRightButton, 'Visible', 'on');
set(handles.topLeftButton, 'Visible', 'on');

handles.PageWindowRectangles = {};
handles.FocusWindowRectangles = {};

colormap(handles.focusWindow,handles.data.cmap);
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

