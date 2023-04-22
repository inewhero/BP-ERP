% ----written by Rayi_Yosoro----
% ----Oct.18 2022----
%% beat generation
cd 'E:\beat\Experiment'
clc;clear;
[filename,path] = uigetfile;
flow = table2cell(readtable(strcat(path,filename),'Sheet', 1,'PreserveVariableNames',false));
prev_next = readtable(strcat(path,filename),'Sheet', 2,'PreserveVariableNames',false);

prev_seq = table2cell(prev_next(1,2:113));
next_seq = table2cell(prev_next(2,2:65));
flow_seq(:,1) = flow(:,1);
for i=1:size(flow,1)
    flow_seq(i,2:1+size(prev_seq,2)) = prev_seq(1,:);
    flow_seq(i,(size(prev_seq,2)+2):(size(prev_seq,2)+2+size(flow,2)-2+size(next_seq,2))) = [flow(i,2:size(flow,2)) next_seq(1,:)];
end
standard_seq(1,2:257) = repmat(next_seq, 1, 4);
standard_seq(1,1) = cellstr('0000');
flow_seq = [flow_seq;standard_seq];
save('stimulus_seq.mat','flow_seq')

%% bufferdata generation
cd 'EXPERIMENT DIR'
clc;clear;
load stimulus_seq.mat

Fs = 48000;     %若实验上位机采样率不为4.8kHz则计时精度不可靠！！！需重新设定duration使采样点为整数！！！
T = 0.0375;     %duration
f = 500;          %beep freq
beep = sin(2*pi*f*(0:T*Fs-1)/Fs);
blankbeep = zeros(1,Fs*T);
firstbeep =  sin(4*pi*f*(0:T*Fs-1)/Fs); %firstbeep's freq is 2*f=1kHz

audio_seq = zeros(size(flow_seq,1),(size(flow_seq,2)-1)*Fs*T);
flow_header = flow_seq(:,1);
flow_seq = cell2mat(flow_seq(:,2:size(flow_seq,2)));

for i=1:size(flow_seq,1)
    for j=1:size(flow_seq,2)
        if flow_seq(i,j) == 1
            audio_seq(i,((j-1)*1800+1):j*1800) = beep;      %matlab bug: replace 1800 to set T*Fs
        elseif flow_seq(i,j) == 0
            audio_seq(i,((j-1)*1800+1):j*1800) = blankbeep;
        end
    end
    fprintf('当前生成进度：%f。\n', i/size(flow_seq,1));
end
audio_seq(:,1:1800) = repmat(firstbeep,i,1);    %replace first beep to 1kHz

flow_seq = [flow_header num2cell(flow_seq)];

guideOP = imread('guide-1.jpg');
guideED = imread('guide-2.jpg');
audioOP = audioread('exp_guide.mp3');
audioED = audioread('exp_ending.mp3');

save('exp_seq.mat','flow_seq','audio_seq','guideOP','guideED','audioOP','audioED')
