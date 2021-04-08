%% SysID data processing 
% File to load in Gripable force data and FES stimulus from file saved in
% simulink 
clear all; close all; 

T1 = load('FES_force_AY_21_03_11_1.mat');
% T2 = load('FES_force_CB_21_03_12_4.mat');
T2 = load('FES_force_JN_21_03_11_1.mat');
T3 = load('FES_force_XS_21_03_11_1.mat');
% T5 = load('FES_force_PZ_21_03_12_7L.mat');
% T6 = load('FES_force_AY_21_03_11_4L.mat');

T1_input = T1.ans.data(1:408024,2);
T1_output = T1.ans.data(1:408024,1);
T1_time = T1.ans.time(1:408024);
T1_smoothed_output = smoothdata(T1_output, 'SmoothingFactor', 0.03);

V1_input = T1.ans.data(408024:end,2);
V1_output = T1.ans.data(408024:end,1);
% V1_time = T1.ans.time;
V1_smoothed_output = smoothdata(V1_output, 'SmoothingFactor', 0.03);

T2_input = T2.ans.data(1:366550,2);
T2_output = T2.ans.data(1:366550,1);
T2_time = T2.ans.time(1:366550);
T2_smoothed_output = smoothdata(T2_output, 'SmoothingFactor', 0.03);

V2_input = T2.ans.data(366550:end,2);
V2_output = T2.ans.data(366550:end,1);
% V2_time = T2.ans.time;
V2_smoothed_output = smoothdata(V2_output, 'SmoothingFactor', 0.03);

T3_input = T3.ans.data(1:365995,2);
T3_output = T3.ans.data(1:365995,1);
T3_time = T3.ans.time(1:365995);
T3_smoothed_output = smoothdata(T3_output, 'SmoothingFactor', 0.03);

V3_input = T3.ans.data(365995:end,2);
V3_output = T3.ans.data(365995:end,1);
% V3_time = T3.ans.time;
V3_smoothed_output = smoothdata(V3_output, 'SmoothingFactor', 0.03);

%% Model identification 

% H_mdl = idnlhw([2, 3, 1], 'pwlinear', 'pwlinear', 'Ts', 0.001)
% mdl_AY = nlhw(iddata(T1_input,T1_smoothed_output, 0.001), H_mdl)
% figure; 
% compare(iddata(V1_input, V1_smoothed_output, 0.001), mdl_AY)

H_mdl = idnlhw([2, 3, 1], 'pwlinear', 'pwlinear', 'Ts', 0.001)
mdl_AY = nlhw(iddata(T1_smoothed_output, T1_input, 0.001), H_mdl)
figure; 
compare(iddata(V1_smoothed_output, V1_input, 0.001), mdl_AY)

mdl_JN = nlhw(iddata(T2_smoothed_output, T2_input, 0.001), H_mdl)
figure; 
compare(iddata(V2_smoothed_output, V2_input, 0.001), mdl_JN)

mdl_XS = nlhw(iddata(T3_smoothed_output, T3_input, 0.001), H_mdl)
figure; 
compare(iddata(V3_smoothed_output, V3_input, 0.001), mdl_XS)




%% Plot

figure;
yyaxis left
plot(T1_time, T1_input)
ylabel('Stim amplitude (mA)')
yyaxis right
plot(T1_time, T1_smoothed_output)
ylabel('Force')
xlabel('Time (s)')
title('AY')


figure
yyaxis left
plot(T2_time, T2_input)
ylabel('Stim amplitude (mA)')
yyaxis right
plot(T2_time, T2_smoothed_output)
ylabel('Force')
xlabel('Time (s)')
title('JN')

figure
yyaxis left
plot(T3_time, T3_input)
ylabel('Stim amplitude (mA)')
yyaxis right
plot(T3_time, T3_smoothed_output)
ylabel('Force')
xlabel('Time (s)')
title('XS')
