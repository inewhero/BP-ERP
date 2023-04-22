% ----written by Rayi_Yosoro----
% ----Apr.08 2023----
clc;clear;sca;
%% Select re-reference method
reref_options = {'Average', 'Mastoid (TP9/TP10)'};
reref_method = 1;   %average reref as default
[reref_method, ~] = listdlg('ListString', reref_options, 'SelectionMode', 'single', 'Name', 'Re-reference (exclude HEOG/VEOG)', 'PromptString', 'Choose re-reference method:', 'ListSize', [500,100], 'InitialValue', reref_method);
if reref_method == 1
    input_dir = 'INPUT DIR\average\';
    output_dir = 'OUTPUT DIR\average\';
elseif reref_method == 2
    input_dir = 'INPUT DIR\mastoid\';
    output_dir = 'OUTPUT DIR\mastoid\';
end

cd(input_dir)
data_list = dir('*.set');

%% EEGLAB, Start!
[ALLEEG , ~, CURRENTSET, ALLCOM] = eeglab;

for i=1:length(data_list)
    clear EEG;
    participant = split(data_list(i).name, '_');
    %% Load EEGLAB dataset
    EEG = pop_loadset(char(data_list(i).name));
    
    %% Create ICLabel and viewprops
    % for classify component by eyes
%     EEG = iclabel(EEG);
%     pop_viewprops(EEG, 0, [1:size(EEG.icaweights,1)], {'freqrange' [0.1 60]});
%     input(strcat('\nCurrent dataset: [ ', char(participant(1)), ' ]. Press Enter to continue.\n'));
    
    %% Remove components
    full_component = [1:size(EEG.icaweights,1)];
    if isequal(char(participant(3)), 'M.set')
        switch char(participant(1))
% SOME CASE like 
%             case 'xxx'
%                 keep_component = [];
            otherwise
                input('Component parameter not found, check dataset!\n');
        end
    elseif isequal(char(participant(3)), 'A.set')
        switch char(participant(1))
% SOME CASE like 
%             case 'xxx'
%                 keep_component = [];
            otherwise
                input('Component parameter not found, check dataset!\n');
        end
    end
    remove_component = setdiff(full_component, keep_component);
    EEG.reject.gcompreject = ismember(full_component, remove_component);    %mark component to be removed
    EEG = pop_subcomp(EEG, remove_component, 0);
    EEG = eeg_checkset(EEG);
    
    %% Create eventlist and detect artifacts
    EEG = pop_creabasiceventlist(EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', 'YOUR EVENTLIST PATH');
    EEG = pop_binlister(EEG , 'BDF', 'YOUR BIN PATH\bin.txt', 'ExportEL', 'YOUR EVENTLIST PATH\eventlist.txt', 'Forbidden',  -99, 'IndexEL',  1, 'SendEL2', 'All', 'Voutput', 'EEG');
    EEG = pop_epochbin(EEG , [-100.0  400.0],  'pre');
    EEG = pop_artextval(EEG , 'Channel',  [1:EEG.nbchan], 'Flag',  1, 'Threshold', [-100 100], 'Twindow', [-100 400]);
    EEG = pop_rejepoch(EEG, EEG.reject.rejmanual, 0);
    
    %% Create average and set new bins for diff waves
    ERP = pop_averager(EEG, 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on', 'Warning', 'off');   %compute average and generate ERP for single dataset
    ERP = pop_binoperator(ERP, 'YOUR BIN PATH\beat_bin_full_diff.txt');    %new bin for diff
    
    %% Save ERPsets
    current_erpname = strcat(char(participant(1)), '_', char(participant(3)));
    current_erpname = current_erpname(1:length(current_erpname)-4);
    ERP.erpname = [current_erpname '_diff'];      %name erpset without elegant code...
    pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', output_dir, 'warning', 'off');
    
end

