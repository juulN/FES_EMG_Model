%% Open loop FES control - 
% Syncs with Simulink model calibrationSim
clc; clear all; close all;

%% Set up Bluetooth connection with Technalia FES device and Init UDP ports
bt = bluetooth("0016A474B78F", 1);  %MAC address of device 
writeline(bt,"iam DESKTOP");
writeline(bt,"battery ? ");
writeline(bt,"elec 1 *pads_qty 16");

elecname = "testname1"

% Init UDP ports for simulink comms 
% matlab and simulink need to be separate instances (same computer)
% u1 = udpport("LocalPort",12383) %increase by one if error
% u2 = udpport("LocalPort",22383) %increase by one if error
% 

% Write new stim file (last char of string not transmitted -> add space at end of string)
writeline(bt, "sdcard rm default/test/ve5.ptn ")
writeline(bt, "sdcard cat > default/test/ve5.ptn ")
writeline(bt, "sdcard ed default/test/ve5.ptn CONST CONST R 100 100 3000 ") % 
                             %amplitude 
                             %pulsewith 
                             %time(us)(1ms -3000ms)
                                           
writeline(bt,strcat("stim on"));
stimMA = 0;

%% Set parameters/initialise model
buffer = 1000; % Buffer for?? 

%% Set safety limits here 
stimMax = 400; %20mA for aaron
forceMax = 0.2;
stimAmp = 8;

%% Start recording for calibration
% Ensure real-time kernell is installed
open 'calibrationSim'

%% Pulses 
elec = [1, 5, 12];
% Start stim for calibration
for finger = 1:3
    set_param('calibrationSim','SimulationCommand','start')
    for j = 1:3
    i = 100;
        while (i<=stimMax)
        force = read(u2,buffer,"double");
    %     b = uint8(abs(a(1))*stimCalibration)

            stimMA = uint8(i)     
            if (stimMA <= stimMax && force(buffer) < forceMax)
                writeline(bt,strcat("freq ",num2str(200)));
                cmd = generate_command(elec(finger), [stimAmp], [stimMA], elecname);
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                write(u1,stimMA,"double","LocalHost",5000);
            else
                stimMax = stimMA
                forceMax = force(buffer)
                stimMA = 0;
                cmd = generate_command(elec(finger), [stimAmp], [stimMA], elecname);
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                writeline(bt,strcat("stim off"));
                write(u1,stimMA,"double","LocalHost",5000);
                break;
            end
            pause(3) 
            stimMA = 0
            writeline(bt,strcat("freq ",num2str(200)));
            cmd = generate_command(elec(finger), [stimAmp], [stimMA], elecname);
            writeline(bt,cmd)
            writeline(bt,strcat("stim ",elecname));
            write(u1,stimMA,"double","LocalHost",5000);
            pause(3)
            i = i+50;

        end
    end
    set_param('calibrationSim','SimulationCommand','stop')
    filename = sprintf('calibrationRecording_%s', datestr(now,'mm-dd-yyyy HH-MM'));
    save(filename, 'calibrationRecording') 
    
    H_mdl = idnlhw([2, 3, 1], 'pwlinear', 'unitgain', 'Ts', 0.001); 

    % Divide data for identification and validation
    halfIdx = ceil(size(calibrationRecording.time,1)/2);

    stimAmpID = calibrationRecording.data(1:halfIdx,2);
    gripForceID = smoothdata(calibrationRecording.data(1:halfIdx,1), 'SmoothingFactor', 0.03');

    stimAmpV = calibrationRecording.data(halfIdx+1:end,2);
    gripForceV = smoothdata(calibrationRecording.data(halfIdx+1:end,1), 'SmoothingFactor', 0.03');
    mdl(finger) = nlhw(iddata(stimAmpID, gripForceID, 0.001), H_mdl); 

end 


%% ID Hammerstein Model from calibration data 
disp('Identifying model, please wait...')


%
% T1 = load('FES_force_AY_21_03_11_1.mat');
% stimAmpID = T1.ans.data(1:408024,2);
% gripForceID = smoothdata(T1.ans.data(1:408024,1), 'SmoothingFactor', 0.03);
% 
% stimAmpV = T1.ans.data(408024:end,2);
% gripForceV = smoothdata(T1.ans.data(408024:end,1), 'SmoothingFactor', 0.03);

%
plot(mdl(1))
plot(mdl(2))
plot(mdl(3))

hw_mdl1 = mdl(1);
hw_mdl2 = mdl(2);
hw_mdl3 = mdl(3);

%%

open 'FEScontrollerSim' 
set_param('FEScontrollerSim','SimulationCommand','start')

while True
            FESstim = read(u2,buffer,"double");
            writeline(bt,strcat("freq ",num2str(200)));
            cmd = generate_command(elec(finger), [stimAmp], [FESstim], elecname);
            writeline(bt,cmd)
            writeline(bt,strcat("stim ",elecname));
            write(u1,stimMA,"double","LocalHost",5000);
end


