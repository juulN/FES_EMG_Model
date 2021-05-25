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
                                     % %pulsewith 
                             % time(us)(1ms -3000ms)
                      % %amplitude 
                      
%% test
% writeline(bt,strcat("freq ",num2str(200)));
% cmd = generate_command([15], [7], [300], elecname);
% writeline(bt,cmd)
% writeline(bt,strcat("stim ",elecname));
%% Select elecs
maxAmp = 12;
elecArray = selectElec(bt, maxAmp)
%% Set parameters/initialise model
buffer = 1000; % Buffer for?? 

%% Set safety limits here 
stimMax = 9; %20mA for aaron
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
            writeline(bt,strcat("freq ",num2str(200)));
            cmd = generate_command([15], [stimMA], [400], elecname);
            writeline(bt,cmd)
            writeline(bt,strcat("stim ",elecname));
            write(u1,stimMA,"double","LocalHost",5000);
        else
            stimMax = stimMA
            forceMax = force(buffer)
            stimMA = 0;
            cmd = generate_command([15], [stimMA], [400], elecname);
            writeline(bt,cmd)
            writeline(bt,strcat("stim ",elecname));
            writeline(bt,strcat("stim off"));
            write(u1,stimMA,"double","LocalHost",5000);
            break;
        end
        pause(3) 
        stimMA = 0
        writeline(bt,strcat("freq ",num2str(200)));
        cmd = generate_command([15], [stimMA], [400], elecname);
        writeline(bt,cmd)
        clockPrev = clockNew; 
    end
end
%%
% press CTRL+C to stop and send: writeline(bt,"stim off ")
% Stop stimulation with: set_param('openloopFEScontrollerSim','SimulationCommand','stop')
% Save recorded data with: save('openloop_0405_T1', 'controllerData')
writeline(bt,"stim off ")
set_param('openloopFEScontrollerSim','SimulationCommand','stop')

filename = sprintf('OpenLoop_%s', datestr(now,'mm-dd-yyyy HH-MM'));
save(filename, 'controllerData')
