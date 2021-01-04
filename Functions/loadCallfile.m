function [Calls,audiodata,ClusteringData] = loadCallfile(filename,handles)

data = load(filename);

%% Unpack the data
if isfield(data, 'Calls')
    Calls = data.Calls;
else
    error('This doesn''t appear to be a detection file!')
end

if isfield(data, 'audiodata')
    audiodata = data.audiodata;
else
    audiodata = struct();
end

if isfield(data, 'ClusteringData')
    ClusteringData = data.ClusteringData;
else
    ClusteringData = [];
end


%% Make sure there's nothing wrong with the file
if isempty(Calls)
    disp(['No calls in file: ' filename]);
else
    % Backwards compatibility with struct format for detection files
    if isstruct(Calls)
        Calls = struct2table(Calls, 'AsArray', true);
    end
    % Remove calls with boxes of size zero
    Calls(Calls.Box(:,4) == 0, :) = [];
    Calls(Calls.Box(:,3) == 0, :) = [];
end

%Handles are required for audiodata. When handles are missing, return only
%the calls
if isempty(handles)
    return;
end

%% If audiodata isn't present, make it so
if nargout > 1
    if ~isfield(data, 'audiodata') || ~isfield(data.audiodata, 'Filename') || ~isfile(data.audiodata.Filename)
        % Does anything in the audio folder match the filename? If so, assume
        % this is the matching audio file, else select the right one.
        [~, detection_name] = fileparts(filename);
        filename_match = [];
        for i = 1:length(handles.audiofilesnames)
            [~, name_only] = fileparts(handles.audiofiles(i).name);
            filename_match(i) = contains(detection_name, name_only);
        end
        filename_match = find(filename_match);
        
        % Did we find a matching file?
        if ~isempty(filename_match)
            audio_file = fullfile(handles.audiofiles(filename_match).folder, handles.audiofiles(filename_match).name);
        else
            [file, path] = uigetfile({
                '*.wav;*.ogg;*.flac;*.UVD;*.au;*.aiff;*.aif;*.aifc;*.mp3;*.m4a;*.mp4' 'Audio File'
                '*.wav' 'WAVE'
                '*.flac' 'FLAC'
                '*.ogg' 'OGG'
                '*.UVD' 'Ultravox File'
                '*.aiff;*.aif', 'AIFF'
                '*.aifc', 'AIFC'
                '*.mp3', 'MP3 (it''s probably a bad idea to record in MP3'
                '*.m4a;*.mp4' 'MPEG-4 AAC'
                }, sprintf('Importing from standard DeepSquek. Select audio matching the detection file %s',detection_name), detection_name);
            audio_file = fullfile(path, file);
            if isequal(file,0) % If user pressed cancel
                return
            end
        end
        
        audiodata = audioinfo(audio_file);
        disp('Saving call file with updated audio')
        save(filename, 'audiodata', '-append');
    end
    audiodata.samples = audioread(audiodata.Filename);
end
