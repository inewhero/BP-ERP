% ----written by Rayi_Yosoro----
% ----Apr.02 2023----
clc;clear;sca;
%% Select re-reference method
reref_options = {'Average', 'Mastoid (TP9/TP10)'};
reref_method = 1;   %average reref as default
[reref_method, ~] = listdlg('ListString', reref_options, 'SelectionMode', 'single', 'Name', 'Re-reference (exclude HEOG/VEOG)', 'PromptString', 'Choose re-reference method:', 'ListSize', [500,100], 'InitialValue', reref_method);
input_dir = 'INPUT DIR';
if reref_method == 1
    output_dir = 'OUTPUT DIR\average\';
elseif reref_method == 2
    output_dir =  'OUTPUT DIR\mastoid\';
end

cd(input_dir)
data_list = dir('*.vhdr');

%% Load data to EEGLAB
[ALLEEG , ~, CURRENTSET, ALLCOM] = eeglab;
for i=1:length(data_list)
    clear EEG;

    %% Load brainvison .vhdr
    EEG = pop_loadbv(input_dir, char(data_list(i).name));
    
    %% Channel location
    EEG = pop_chanedit(EEG, 'lookup', locationfile, 'changefield', {32 'labels' 'HEOG'}, 'changefield', {63 'labels' 'VEOG'}, 'lookup', locationfile);
    
    %% Re-reference (exclude EOG)
    if reref_method == 2
        EEG = pop_reref(EEG, {'TP9' 'TP10'}, 'exclude', [32 63]);  %mastoid
        reref_method = 'M';
    elseif reref_method == 1
        EEG = pop_reref(EEG, [], 'exclude', [32 63]);  %average
        reref_method = 'A';
    end
    
    %% Filtering
    % Apr.08 Epoch funtion removed due to marker 'boundary' will erase other
    % markers and accur data lost.
    EEG = pop_eegfiltnew(EEG, 0.1, 20);
%     EEG = pop_epoch(EEG, [], [-0.6 1.0]);   %Standard IOI is 600ms 
%     EEG = pop_rmbase(EEG, [-0.6 0]);
    
    %% Interpolation for specific participants
    switch char(data_list(i).name)
        case 'SOME CASE1'
            EEG = pop_interp(EEG, [36], 'spherical');  %AF8_#36_
        case 'SOME CASE2'
            EEG = pop_interp(EEG, [36], 'spherical');  %AF8_#36_
        case 'SOME CASE3'
            EEG = pop_interp(EEG, [48], 'spherical');   %T8_#48_
        otherwise
            fprintf('Interpolation skipped.\n');
    end
    EEG = eeg_checkset(EEG);
    
    %% ICA
    EEG = pop_runica(EEG, 'extended', 1, 'icatype', 'runica', 'chanind', 1:EEG.nbchan);
    
    %% Save dataset
    ICAed_name = strcat(data_list(i).name(1:length(data_list(i).name)-5), '_ICAed_', reref_method, '.set');
    EEG = pop_saveset(EEG, 'filename', ICAed_name, 'filepath', output_dir);
    
end
    