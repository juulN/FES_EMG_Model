%% plot controller data
% Script to plot controller data FES controller sim 
% clear all; close all; clc
load('openloopT28.mat', 'controllerData')

figure; 
sgtitle('Open loop control')
subplot(2,1,1)
title('Force trajectory')
plot(controllerData.time, controllerData.data(:,4), 'LineWidth', 1)
hold on 
plot(controllerData.time, controllerData.data(:,5), 'LineWidth', 1)
hold off
legend('Desired', 'Measured')
grid on 
grid minor
ylabel('Force') 
subplot(2,1,2)
title('Stimulus pulsewidth') 
plot(controllerData.time, controllerData.data(:,1), 'LineWidth', 1)
hold on 
plot(controllerData.time, controllerData.data(:,2), 'LineWidth', 1)
plot(controllerData.time, controllerData.data(:,3), 'LineWidth', 1)
hold off
ylabel('Pulsewidth (\mus)')
xlabel('Time (s)')
legend('Electrode 1', 'Electrode 2', 'Electrode 3') 
grid on 
grid minor

%%
load('hmdls_0426_28.mat')
plot(h_mdls{1})
% plot(h_mdls{2})
% plot(h_mdls{3})




%%
load('calibrationRecording_04-26-2021 17-05.mat')
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
compare(iddata(stimAmpV,gripForceV, 0.001), h_mdls{1})
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
load('calibrationRecording_04-26-2021 11-36.mat')
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