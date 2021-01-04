function [I,windowsize,noverlap,nfft,rate,box,s,fr,ti,audio] = CreateFocusSpectrogram(call,handles, make_spectrogram,options, audioReader)
%% Extract call features for CalculateStats and display


if nargin < 3
    make_spectrogram = true;
end

if nargin < 4 || isempty(options)
    options = struct;
    options.frequency_padding = 0;
    options.nfft = 0.0032;
    options.overlap = 0.0028;
    options.windowsize = 0.0032;
end

rate = call.Rate;
box = call.Box;

% if ~isfield(handles,'current_focus_position')
%     handles.current_focus_position = [];
% end
% 
% if ~isempty(handles.current_focus_position) & handles.current_focus_position(1) < 0
%     handles.current_focus_position(1) = 0;
% end

%
% call_box_in_samples = round(handles.data.audiodata.SampleRate*box);
% call_box_start = call_box_in_samples(1);
% call_box_end = call_box_in_samples(1) + call_box_in_samples(3);
%
% call_box_offset = 0;
% window_width = call_box_in_samples(3);


% window_start = max(call_box_start - call_box_offset, 0);
% window_stop = min(call_box_end + call_box_offset, handles.data.audiodata.Duration);
%
% if window_start == 1
%     window_stop = window_start + seconds* handles.data.audiodata.SampleRate;
% elseif window_start > window_stop
%     warning('Callbox extends beyond audio duration.');
%     window_start = window_stop -  window_width;
% end

% audio = handles.data.audiodata.samples(round(window_start):round(window_stop));

windowsize = round(rate * options.windowsize);
noverlap = round(rate * options.overlap);
nfft = round(rate * options.nfft);

if make_spectrogram
    audio = audioReader.AudioSamples(box(1), box(1) + box(3));
    [s, fr, ti] = spectrogram(audio,windowsize,noverlap,nfft,rate,'yaxis');
else
%     s  = handles.data.page_spect.s;
%     fr = handles.data.page_spect.f;
%     ti = handles.data.page_spect.t;
    
    s  = handles.data.page_spect.s(:,handles.data.page_spect.t > call.Box(1) & handles.data.page_spect.t < sum(call.Box([1,3])));
    ti = handles.data.page_spect.t(  handles.data.page_spect.t > call.Box(1) & handles.data.page_spect.t < sum(call.Box([1,3])));
    fr = handles.data.page_spect.f;

end
    

%% Get the part of the spectrogram within the box
x1 = 1;
x2 = length(ti);

y1=find(fr./1000>=round(call.Box(2)-options.frequency_padding),1);
max_freq = round(call.Box(2)+call.Box(4)+options.frequency_padding);
kHz = fr./1000;
y2=find(kHz>=min(max_freq,max(kHz)),1);
I=abs(s(y1:y2,x1:x2));


end