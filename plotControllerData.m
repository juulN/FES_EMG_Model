%% plot controller data
% Script to plot controller data FES controller sim 
% clear all; close all; clc
load('OpenLoop_05-04-2021 17-50', 'controllerData')
controllerData.data(:,4) = controllerData.data(:,4) * 70 * 9.81; 
controllerData.data(:,5) = controllerData.data(:,5) * 70 * 9.81; 
figure; 
% sgtitle('Open loop control')
subplot(2,1,1)
title('Force trajectory')
% plot(controllerData.time, controllerData.data(:,4), 'LineWidth', 1)
hold on 
plot(controllerData.time, controllerData.data(:,5), 'LineWidth', 1)
hold off
xlim([21.98 22.06])
ylim([0 50])
% legend('Desired', 'Measured')
legend('Measured')
grid on 
grid minor
ylabel('Force (N)') 
% subplot(4,1,2)
% title('Stimulus pulsewidth') 
% plot(controllerData.time, controllerData.data(:,1), 'LineWidth', 1)
% hold on 
% % plot(controllerData.time, controllerData.data(:,2), 'LineWidth', 1)
% % plot(controllerData.time, controllerData.data(:,3), 'LineWidth', 1)
% hold off
% xlim([0 200])
% ylabel('Pulsewidth (\mus)')
% xlabel('Time (s)')
% % legend('Electrode 1', 'Electrode 2', 'Electrode 3') 
% grid on 
% grid minor

subplot(2,1,2)
% plot(SinAY.Time(220586:end)/1000, SinAY.ExtAUX1(220586:end))    % Sampling rate is 1kHz
% hold on 
% plot(SinAY.Time(220586:end)/1000, SinAY.FlexAUX2(220586:end))
% plot(SinVolAY2.Time/1000, SinVolAY2.ExtAUX1-SinVolAY2.ExtAUX1(1))  
plot([0:0.001:222.000],outEMGsim(:,2)-outEMGsim(1,2))

% Sampling rate is 1kHz
title('Flexor EMG') 

hold off 
xlim([21.98 22.06])

ylabel('EMG (\uV)')
xlabel('Time (s)')
title('Flexor EMG') 
grid on 
grid minor

figure;
subplot(4,1,4)
title('EMG') 
% plot(SinAY.Time(220586:end)/1000, SinAY.ExtAUX1(220586:end))    % Sampling rate is 1kHz
% hold on 
% plot(SinAY.Time(220586:end)/1000, SinAY.FlexAUX2(220586:end))
% plot(SinVolAY2.Time/1000, SinVolAY2.ExtAUX1)    % Sampling rate is 1kHz
% hold on 
plot(SinVolAY2.Time/1000, SinVolAY2.FlexAUX2)
hold off 
xlim([0 200])
ylabel('EMG (\uV)')
xlabel('Time (s)')
legend('Extensor') 
grid on 
grid minor
%%
load('OpenLoop_05-04-2021 17-46', 'controllerData')
controllerData.data(:,4) = controllerData.data(:,4) * 70 * 9.81; 
controllerData.data(:,5) = controllerData.data(:,5) * 70 * 9.81; 
figure; 
% sgtitle('Open loop control')
subplot(4,1,1)
title('Force trajectory')
% plot(controllerData.time, controllerData.data(:,4), 'LineWidth', 1)
hold on 
plot(controllerData.time, controllerData.data(:,5), 'LineWidth', 1)
hold off
xlim([0 600])
% legend('Desired', 'Measured')
legend('Measured')
grid on 
grid minor
ylabel('Force') 
subplot(4,1,2)
title('Stimulus pulsewidth') 
% plot(controllerData.time, controllerData.data(:,1), 'LineWidth', 1)
hold on 
plot(controllerData.time, controllerData.data(:,2), 'LineWidth', 1)
% plot(controllerData.time, controllerData.data(:,3), 'LineWidth', 1)
hold off
xlim([0 600])
ylabel('Pulsewidth (\mus)')
xlabel('Time (s)')
% legend('Electrode 1', 'Electrode 2', 'Electrode 3') 
grid on 
grid minor

subplot(4,1,3)
% plot(SinAY.Time(220586:end)/1000, SinAY.ExtAUX1(220586:end))    % Sampling rate is 1kHz
% hold on 
% plot(SinAY.Time(220586:end)/1000, SinAY.FlexAUX2(220586:end))
plot(SinVolAY1.Time/1000, SinVolAY1.ExtAUX1-SinVolAY1.ExtAUX1(1))    % Sampling rate is 1kHz
hold on
plot([0:0.001:600.000],flexsinvolay1filt)
hold off 
xlim([0 600])
ylabel('EMG (\uV)')
xlabel('Time (s)')
title('Flexor EMG') 
legend('sEMG', 'filtered sEMG') 

grid on 
grid minor

subplot(4,1,4)
% plot(SinAY.Time(220586:end)/1000, SinAY.ExtAUX1(220586:end))    % Sampling rate is 1kHz
% hold on 
% plot(SinAY.Time(220586:end)/1000, SinAY.FlexAUX2(220586:end))
% plot(SinVolAY2.Time/1000, SinVolAY2.ExtAUX1)    % Sampling rate is 1kHz
% hold on 
plot(SinVolAY1.Time/1000, SinVolAY1.FlexAUX2-SinVolAY1.FlexAUX2(1))
hold on 
plot([0:0.001:600.000],outEMGsim(:,6))
hold off 
xlim([0 600])
ylabel('EMG (\uV)')
xlabel('Time (s)')
title('Extensor EMG') 

legend('sEMG', 'filtered sEMG') 
grid on 
grid minor
%%
load('OpenLoop_05-04-2021 17-34', 'controllerData')
controllerData = getsampleusingtime(controllerData, 5, 275);
controllerData.data(:,4) = controllerData.data(:,4) * 70 * 9.81; 
controllerData.data(:,5) = controllerData.data(:,5) * 70 * 9.81; 

RMSE = sqrt(mean((controllerData.data(:,4)- controllerData.data(:,5)).^2))
figure; 
% sgtitle('Open loop control')
subplot(2,1,1)
title('Force trajectory')
plot(controllerData.time, controllerData.data(:,4), 'LineWidth', 1)
hold on 
plot(controllerData.time, controllerData.data(:,5), 'LineWidth', 1)
hold off
% xlim([5 275])
legend('Desired', 'Measured')
% legend('Measured')
grid on 
grid minor
ylabel('Force (N)') 
title('Grip force')

% % figure
% subplot(4,1,2)
% title('Stimulus pulsewidth') 
% % plot(controllerData.time, controllerData.data(:,1), 'LineWidth', 1)
% hold on 
% plot(controllerData.time, round(controllerData.data(:,2),-1), 'LineWidth', 1)
% % plot(controllerData.time, controllerData.data(:,3), 'LineWidth', 1)
% hold off
% % xlim([5 275])
% ylabel('Pulsewidth (\mus)')
% xlabel('Time (s)')
% % legend('Electrode 1', 'Electrode 2', 'Electrode 3') 
% grid on 
% grid minor

% figure
subplot(2,1,2)
% plot(SinAY.Time/1000, SinAY.ExtAUX1)    % Sampling rate is 1kHz
plot([0:0.001:222.000],outEMGsim(:,6))

% hold on 
% plot(SinAY.Time(220586:end)/1000, SinAY.FlexAUX2(220586:end))
% plot(SinVolAY1.Time/1000, SinVolAY1.ExtAUX1)    % Sampling rate is 1kHz
title('Flexor EMG') 

hold off 
xlim([0 550])
ylabel('EMG (\uV)')
xlabel('Time (s)')
% legend('Flexor') 
grid on 
grid minor

figure
subplot(4,1,4)
title('EMG') 
% plot(SinAY.Time(220586:end)/1000, SinAY.ExtAUX1(220586:end))    % Sampling rate is 1kHz
% hold on 
plot(SinAY.Time/1000, SinAY.FlexAUX2)
% plot(SinVolAY2.Time/1000, SinVolAY2.ExtAUX1)    % Sampling rate is 1kHz
% hold on 
% plot(SinVolAY1.Time/1000, SinVolAY1.FlexAUX2)
hold off 
title('Extensor EMG')
xlim([0 550])
ylabel('EMG (\uV)')
xlabel('Time (s)')
% legend('Extensor') 
grid on 
grid minor
%%
figure;
signal = SinVolAY1.FlexAUX2;
y = fft(signal); 
fs = 1000;
f = (0:length(y)-1)*fs/length(y);
plot(f, abs(y))
signal2 = SinVolAY1.FlexAUX2;

%%
fs = 1000;
fo = 20; 
q = 3; 
bw = (fo/(fs/2))/q; 

[num, den] = iircomb(fs/fo, bw, 'notch'); 
combFilt = dsp.IIRFilter('Numerator', num ,'Denominator', den); 
fvtool(num, den)

d = designfilt('bandstopiir','FilterOrder',4, ...
               'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
               'DesignMethod','butter','SampleRate',fs);
%%
x = combFilt(signal);
x = filtfilt(d, x); 
figure
title('EMG') 
plot(SinVolAY1.Time/1000, SinVolAY1.FlexAUX2)    % Sampling rate is 1kHz\
hold on 
plot(SinVolAY1.Time/1000, x)
hold off
%%
[num, den] = iircomb(fs/fo, bw, 'notch'); 
combFilt2 = dsp.IIRFilter('Numerator', num ,'Denominator', den); 
fvtool(num, den)

x2 = combFilt2(signal2);
x2 = filtfilt(d,signal);
figure
title('EMG') 
plot(SinVolAY1.Time/1000, x2)
hold on 
plot(SinVolAY1.Time/1000, SinVolAY1.FlexAUX2)    % Sampling rate is 1kHz

% fvtool(d, 'Fs', 1000)

Fs=1000;
L=length(signal);
t=L/Fs;
% x=signal;

Y = fft(x);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
figure
plot(f,P1) 
title('Frequency Spectrum Plot')
xlabel('f (Hz)')
ylabel('|P1(f)|')


Y = fft(x2);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
figure
plot(f,P1) 
title('Frequency Spectrum Plot')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%%
load('hmdls_0426_27.mat')
plot(h_mdls{1})
% plot(h_mdls{2})
% plot(h_mdls{3})




%%
load('calibrationRecording_04-26-2021 16-52.mat')
plot(calibrationRecording.Data)
inputNL = pwlinear('NumberOfUnits', 7);
h_mdl_struct = idnlhw([2 3 1], inputNL, []); 
halfIdx = ceil(size(calibrationRecording.time,1)/2);
   
stimAmpID = calibrationRecording.data(1:halfIdx,2);
gripForceID = smoothdata(calibrationRecording.data(1:halfIdx,1), 'SmoothingFactor', 0.03');
%     
stimAmpV = calibrationRecording.data(halfIdx+1:end,2);
gripForceV = smoothdata(calibrationRecording.data(halfIdx+1:end,1), 'SmoothingFactor', 0.03');
mdl= nlhw(iddata(gripForceID, stimAmpID, 0.001), h_mdl_struct); 
mdl2= nlhw(iddata(stimAmpID,gripForceID, 0.001), h_mdl_struct); 

plot(mdl)
figure; 
compare(iddata(gripForceV, stimAmpV, 0.001), mdl)
figure;
compare(iddata(stimAmpV,gripForceV, 0.001), mdl2)
%%
load('calibrationRecording_04-26-2021 11-30.mat')
h_mdl_struct = idnlhw([2 3 1], 'pwlinear', []); 
halfIdx = ceil(size(calibrationRecording.time,1)/2);
   
stimAmpID = calibrationRecording.data(1:halfIdx,2);
gripForceID = smoothdata(calibrationRecording.data(1:halfIdx,1), 'SmoothingFactor', 0.03');
%     
stimAmpV = calibrationRecording.data(halfIdx+1:end,2);
gripForceV = smoothdata(calibrationRecording.data(halfIdx+1:end,1), 'SmoothingFactor', 0.03');
mdl= nlhw(iddata(gripForceID, stimAmpID, 0.001), h_mdl_struct); 
plot(mdl)
figure; 
compare(iddata(gripForceV, stimAmpV, 0.001), mdl)
figure;
compare(iddata(stimAmpV,gripForceV, 0.001), h_mdls{2})
%%
load('calibrationRecording_04-26-2021 13-21.mat')
h_mdl_struct = idnlhw([2 3 1], 'pwlinear', []); 
halfIdx = ceil(size(calibrationRecording.time,1)/2);
   
stimAmpID = calibrationRecording.data(1:halfIdx,2);
gripForceID = smoothdata(calibrationRecording.data(1:halfIdx,1), 'SmoothingFactor', 0.03');
%     
stimAmpV = calibrationRecording.data(halfIdx+1:end,2);
gripForceV = smoothdata(calibrationRecording.data(halfIdx+1:end,1), 'SmoothingFactor', 0.03');
mdl= nlhw(iddata(gripForceID, stimAmpID, 0.001), h_mdl_struct); 
plot(mdl)
figure; 
compare(iddata(gripForceV, stimAmpV, 0.001), mdl)
figure;
compare(iddata(stimAmpV,gripForceV, 0.001), h_mdls{3})