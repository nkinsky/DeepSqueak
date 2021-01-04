function  renderEpochSpectogram(hObject, handles, force_render)
%Plot current spectogram window

% if force_render, always remake the spectrogram. This is used when the
% page is changed.

% update the position of the page window

% only remake the spectrogram is the page window changed
if handles.data.lastWindowPosition ~= handles.data.windowposition || force_render
    handles.data.lastWindowPosition = handles.data.windowposition;
    windowsize = round(handles.data.audiodata.SampleRate * 0.0032);
    noverlap = round(handles.data.audiodata.SampleRate * 0.0016);
    nfft = round(handles.data.audiodata.SampleRate * 0.032);
    
    % Get audio within the page range, padded by focus window size
    window_start = handles.data.windowposition - handles.data.settings.focus_window_size/2;
    window_stop = handles.data.windowposition + handles.data.settings.windowSize + handles.data.settings.focus_window_size/2;
    audio = handles.data.AudioSamples(window_start, window_stop);
    
    % Make the spectrogram
    [zoomed_s, zoomed_f, zoomed_t] = spectrogram(audio,windowsize,noverlap,nfft,handles.data.audiodata.SampleRate,'yaxis');
    zoomed_t = zoomed_t + window_start; % Add the start of the window the time units
    zoomed_s = scaleSpectogram(zoomed_s, hObject, handles);
    
    % Plot Spectrogram in the page view
    set(handles.epochSpect,'Parent',handles.spectogramWindow);
    set(handles.epochSpect,'CData',handles.background);
    
    set(handles.epochSpect,'Parent',handles.spectogramWindow);
    set(handles.spectogramWindow, 'Xlim', [handles.data.windowposition, handles.data.windowposition + handles.data.settings.windowSize]);
    set(handles.epochSpect,'CData',zoomed_s,'XData',  zoomed_t,'YData',zoomed_f/1000);
    
    % Plot Spectrogram in the focus view
    set(handles.axes1,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1],'Clim',[0 get_spectogram_max(hObject,handles)]);
    % set(handles.axes1,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1],'Clim',prctile(s_f,[1,99.9],'all'))
    set(handles.spect,'Parent',handles.axes1);
    set(handles.spect,'CData',zoomed_s,'XData', zoomed_t,'YData',zoomed_f/1000);

    % Send the spectrogram back to handles
    handles.data.page_spect.s = zoomed_s;
    handles.data.page_spect.f = zoomed_f;
    handles.data.page_spect.t = zoomed_t;
    guidata(hObject, handles);
end

set(handles.spectogramWindow,'YDir', 'normal','YColor',[1 1 1],'XColor',[1 1 1],'Clim',[0 get_spectogram_max(hObject,handles)]);
set(handles.spectogramWindow, 'Ylim',[handles.data.settings.LowFreq, min(handles.data.settings.HighFreq, handles.data.audiodata.SampleRate/2000)]);
set_tick_timestamps(handles.spectogramWindow, 1);






