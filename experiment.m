%% Main Script of Experiment
% ----written by Rayi_Yosoro----
% ----Oct.19 2022----
% ----markerinfo----
% 1: standard stimuli, odd
% 2: standard stimuli, even
% --------------------------------------------------
% 11: 1/8 faster , deviant stimuli, odd
% 12: 1/16 faster , deviant stimuli, odd
% 13: 1/16 slower , deviant stimuli, odd
% 14: 1/8 slower , deviant stimuli, odd
% --------------------------------------------------
% 21: 1/8 faster , deviant stimuli, even
% 22: 1/16 faster , deviant stimuli, even
% 23: 1/16 slower , deviant stimuli, even
% 24: 1/8 slower , deviant stimuli, even
% --------------------------------------------------
% 31: 1/8 faster , following standard stimuli, odd
% 32: 1/16 faster , following standard stimuli, odd
% 33: 1/16 slower , following standard stimuli, odd
% 34: 1/8 slower, following standard stimuli, odd
% --------------------------------------------------
% 41: 1/8 faster , following standard stimuli, even
% 42: 1/16 faster , following standard stimuli, even
% 43: 1/16 slower , following standard stimuli, even
% 44: 1/8 slower, following standard stimuli, even
% ■□□□■□□□■□□□■□□□■□□□■□□□■□□□■□□□

%% mat pak loading
clc;clear;sca;
cd 'EXPERIMENT DIR'
load exp_seq

%% trigger setting
lptport=53280;
lptwrite(lptport,0);
triggerTime=0.005;

%% subinfo
prompt = {'编号', '性别（1=男性，2=女性）', '年龄','接受音乐训练时长/年（0=无）','备注'};
dlg_dims = [1 50];
dlg_title = '被试信息录入';
def_answer = {'','','','0',''};
subinfo = inputdlg(prompt, dlg_title, dlg_dims, def_answer)';
save(strcat('subinfo',char(subinfo(1))),'subinfo');

%% InitializePTB
Screen('Preference', 'SkipSyncTests', 2);      %maybe the script helps
wPtr=0;
blankcolor=[80 80 80]; % set background to grey
KbName('UnifyKeyNames');
[wPtr,~]=Screen('OpenWindow',wPtr,blankcolor,[],32,2);  %create SCREEN handle
Screen(wPtr,'BlendFunction',GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);    % 颜色混合函数BlendFunction，参数均为常用值
HideCursor;
InitializePsychSound;
Screen('Preference', 'Verbosity', 0);   %disable log fprintf to command line
% ----draw tex----
Screen('Preference', 'ConserveVRAM', 64);       %Enable kPsychUseSoftwareRenderer
tex_guideOP = Screen('MakeTexture',wPtr,guideOP);
tex_guideED = Screen('MakeTexture',wPtr,guideED);
% ----time set----
blankTime = 1;  %to eliminate jitter
Time2Record = 4.8;  %600ms*8, point to standard stimuli No.9
Time04 = 0.6;       %600ms
Time08 = 0.3;       %600ms/2
Time16 = 0.15;      %600ms/4
% ----randomize----
rng('shuffle');     %reset radom seed
rad_order = repmat((1:size(flow_seq,1)-1),1,6)';    %blocks*6, time est. is 32 mins
rad_order(:,2)  = rand(size(rad_order,1),1);
rad_order = sortrows(rad_order, 2);
exp_order = zeros(5,1);
for i = 6:size(rad_order,1)*2+5
    if mod(i,2) == 0.
        exp_order(i,1) = rad_order((i-4)/2,1);
    else
        exp_order(i,1) = 0;
    end
end
for i = 1:size(exp_order)
    if exp_order(i,1) == 0
        exp_order(i,1) = size(flow_seq,1);      %replace standard order references from flow_seq
    end
end

%% Zensokuzenshin, YOSORO!
%----guide----
Screen('DrawTexture',wPtr,tex_guideOP);     %guide image
Screen('Flip',wPtr);
pahandle = PsychPortAudio('Open',9,[],[],48000);        %check device ID!
PsychPortAudio('FillBuffer',pahandle,audioOP');
PsychPortAudio('Start',pahandle,0);
WaitSecs(blankTime);
touch=0;
is_over_flag=0;     %flag to recognize whether all the trials is over
while touch==0
    [touch,~,KbCode]=KbCheck;
    if touch==1
        if strcmp(KbName(KbCode),'a')
            Screen('Flip',wPtr);
            PsychPortAudio('Stop',pahandle,1);
            touch=1;
        elseif strcmp(KbName(KbCode),'ESCAPE')
            PsychPortAudio('Stop',pahandle,1);
            Screen('CloseAll')
        else
            touch=0;
        end
    end
end
%----start!----

for i = 1:size(exp_order,1)
    if i > 5     %i<=5 means training
        flow_type = char(flow_seq(exp_order(i),1));
        if isequal(flow_type,'A+08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(1,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time08);
            lptwrite(lptport,14);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time08-triggerTime);
            lptwrite(lptport,44);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'A+16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(2,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time16);
            lptwrite(lptport,13);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time16-triggerTime);
            lptwrite(lptport,43);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'A-08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(3,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record-Time08);
            lptwrite(lptport,11);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time08-triggerTime);
            lptwrite(lptport,41);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'A-16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(4,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record-Time16);
            lptwrite(lptport,12);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time16-triggerTime);
            lptwrite(lptport,42);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif isequal(flow_type,'B+08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(5,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time08);
            lptwrite(lptport,24);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time08-triggerTime);
            lptwrite(lptport,34);   %corrected Mar 12, 2023
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'B+16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(6,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time16);
            lptwrite(lptport,23);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time16-triggerTime);
            lptwrite(lptport,33);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'B-08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(7,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04-Time08);
            lptwrite(lptport,21);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time08-triggerTime);
            lptwrite(lptport,31);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'B-16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(8,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04-Time16);
            lptwrite(lptport,22);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time16-triggerTime);
            lptwrite(lptport,32);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif isequal(flow_type,'C+08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(9,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04+Time08);
            lptwrite(lptport,14);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time08-triggerTime);
            lptwrite(lptport,44);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'C+16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(10,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04+Time16);
            lptwrite(lptport,13);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time16-triggerTime);
            lptwrite(lptport,43);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'C-08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(11,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04-Time08);
            lptwrite(lptport,11);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time08-triggerTime);
            lptwrite(lptport,41);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'C-16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(12,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04-Time16);
            lptwrite(lptport,12);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time16-triggerTime);
            lptwrite(lptport,42);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif isequal(flow_type,'D+08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(13,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04+Time04+Time08);
            lptwrite(lptport,24);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time08-triggerTime);
            lptwrite(lptport,34);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'D+16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(14,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04+Time04+Time16);
            lptwrite(lptport,23);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04-Time16-triggerTime);
            lptwrite(lptport,33);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'D-08')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(15,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04+Time04-Time08);
            lptwrite(lptport,21);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time08-triggerTime);
            lptwrite(lptport,31);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        elseif  isequal(flow_type,'D-16')
            PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(16,:),2,1));
            PsychPortAudio('Start',pahandle,0);
            WaitSecs(Time2Record+Time04+Time04+Time04-Time16);
            lptwrite(lptport,22);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
            WaitSecs(Time04+Time16-triggerTime);
            lptwrite(lptport,32);
            WaitSecs(triggerTime);
            lptwrite(lptport,0);
        end
    elseif i <= 5
        PsychPortAudio('FillBuffer',pahandle,repmat(audio_seq(17,:),2,1));
        PsychPortAudio('Start',pahandle,0);
        WaitSecs(Time2Record);
        lptwrite(lptport,1);    %position 9
        WaitSecs(triggerTime);
        lptwrite(lptport,0);
        WaitSecs(Time04-triggerTime);
        lptwrite(lptport,2);    %position 10
        WaitSecs(triggerTime);
        lptwrite(lptport,0);
        WaitSecs(Time04-triggerTime);
        lptwrite(lptport,1);    %position 11
        WaitSecs(triggerTime);
        lptwrite(lptport,0);
        WaitSecs(Time04-triggerTime);
        lptwrite(lptport,2);    %position 12
        WaitSecs(triggerTime);
        lptwrite(lptport,0);
    end
end
is_over_flag=1;

%----ending----
if is_over_flag==1
    Screen('DrawTexture',wPtr,tex_guideED);     %ending image
    Screen('Flip',wPtr);
    PsychPortAudio('FillBuffer',pahandle,audioED');
    PsychPortAudio('Start',pahandle,0);
    PsychPortAudio('Stop',pahandle,1,[],3);
    PsychPortAudio('Close');
    WaitSecs(blankTime);
end
sca;



PsychPortAudio('Start',pahandle,0);
PsychPortAudio('Stop',pahandle,1,1,1);