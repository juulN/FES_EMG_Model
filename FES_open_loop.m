%% Open loop FES control - 
% Syncs with Simulink model calibrationSim
clc; clear all; close all;

%% Set up Bluetooth connection with Technalia FES device and Init UDP ports
% bt = bluetooth("0016A474B78F", 1);  %MAC address of device 
% writeline(bt,"iam DESKTOP");
% writeline(bt,"battery ? ");
% writeline(bt,"elec 1 *pads_qty 16");

elecname = "testname1"

% Init UDP ports for simulink comms 
% matlab and simulink need to be separate instances (same computer)
u1 = udpport("LocalPort",12383) %increase by one if error
u2 = udpport("LocalPort",22383) %increase by one if error
% 

% Write new stim file (last char of string not transmitted -> add space at end of string)
% writeline(bt, "sdcard rm default/test/ve5.ptn ")
% writeline(bt, "sdcard cat > default/test/ve5.ptn ")
% writeline(bt, "sdcard ed default/test/ve5.ptn CONST CONST R 100 100 3000 ") % 
                             % %amplitude 
                             % %pulsewith 
                             % time(us)(1ms -3000ms)
                                           
% writeline(bt,strcat("stim on"));
stimMA = 0;

buffer = 1000; % Buffer for?? 

%% Set safety limits here 
stimMax = 2; %20mA for aaron
forceMax = 0.2;


%% Start recording for calibration
% Ensure real-time kernell is installed
open 'calibrationSim'
set_param('calibrationSim','SimulationCommand','start')

%% Pulses 

% Start stim for calibration
for j = 1:3
i = 1;
    while (i<=stimMax)
    force = read(u2,buffer,"double");
%     b = uint8(abs(a(1))*stimCalibration)
 
        stimMA = uint8(i)     
        if (stimMA <= stimMax && force(buffer) < forceMax)
%             writeline(bt,strcat("freq ",num2str(200)));
%             cmd = generate_command([16], [stimMA], [400], elecname);
%             writeline(bt,cmd)
%             writeline(bt,strcat("stim ",elecname));
            write(u1,stimMA,"double","LocalHost",5000);
        else
            stimMax = stimMA
            forceMax = force(buffer)
            stimMA = 0;
%             cmd = generate_command([16], [stimMA], [400], elecname);
%             writeline(bt,cmd)
%             writeline(bt,strcat("stim ",elecname));
%             writeline(bt,strcat("stim off"));
            write(u1,stimMA,"double","LocalHost",5000);
            break;
        end
        pause(3) 
        stimMA = 0
%         writeline(bt,strcat("freq ",num2str(200)));
%         cmd = generate_command([16], [stimMA], [400], elecname);
%         writeline(bt,cmd)
%         writeline(bt,strcat("stim ",elecname));
        write(u1,stimMA,"double","LocalHost",5000);
        pause(3)
        i = i+1;

    end
end

set_param('calibrationSim','SimulationCommand','stop')
filename = sprintf('calibrationRecording_%s', datestr(now,'mm-dd-yyyy HH-MM'));
save(filename, 'calibrationRecording') 

%% ID Hammerstein Model from calibration data 
% disp('Identifying model, please wait...')

H_mdl = idnlhw([2, 3, 1], 'pwlinear', 'unitgain', 'Ts', 0.001); 

% Divide data for identification and validation
% halfIdx = ceil(size(calibrationRecording.time,1)/2);
% 
% stimAmpID = calibrationRecording.data(1:halfIdx,2);
% gripForceID = smoothdata(calibrationRecording.data(1:halfIdx,1), 'SmoothingFactor', 0.03');
% 
% stimAmpV = calibrationRecording.data(halfIdx+1:end,2);
% gripForceV = smoothdata(calibrationRecording.data(halfIdx+1:end,1), 'SmoothingFactor', 0.03');

%
T1 = load('FES_force_AY_21_03_11_1.mat');
figure;
plot(T1.ans.data(1:408024,2))
%plot(T1.ans.data(78984:118065,2))
%stimAmpID = T1.ans.data(1:408024,2);
%gripForceID = smoothdata(T1.ans.data(1:408024,1), 'SmoothingFactor', 0.03);

stimAmpID = T1.ans.data(78984:118065,2);
gripForceID = smoothdata(T1.ans.data(78984:118065,1), 'SmoothingFactor', 0.03);

%stimAmpV = T1.ans.data(408024:end,2);
%gripForceV = smoothdata(T1.ans.data(408024:end,1), 'SmoothingFactor', 0.03);

stimAmpV = T1.ans.data(151157:190237,2);
gripForceV = smoothdata(T1.ans.data(151157:190237,1), 'SmoothingFactor', 0.03);
%
mdl = nlhw(iddata(gripForceID, stimAmpID, 0.001), H_mdl); 
plot(mdl)
%CHECK WHEN REAL DATA COLLECTED 
gripForceVestim = sim(mdl,stimAmpV);
mdlFit = goodnessOfFit(gripForceVestim, gripForceV, 'NRMSE'); 
figure; 
compare(iddata(gripForceV, stimAmpV, 0.001), mdl)
    % ADD warning when fit is below a certain threshold -> Recalibrate? 
figure;
% Linearise model !DO more research
linMdl = linapp(mdl, stimAmpV); %0, 12); 
compare(iddata(gripForceV, stimAmpV, 0.001), linMdl)

invLinMdl = inv(linMdl)
plot(invLinMdl)
% disp('...Done')
%%
time =  [0:0.001:0.001*(size(gripForceV)-1)]; 
stimPred = lsim(invLinMdl, gripForceV,time)

figure; 
plot(stimPred)
