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

%% Set parameters/initialise model
buffer = 1000; % Buffer for?? 
elecArray = [16, 1, 5]; % Electrode number for each finger 
stimMax = 2; %20mA for aaron
forceMax = 0.2;
h_mdl_struct = idnlhw([2 3 1], 'pwlinear', []); 

%% Identification of model for each electrode
h_mdls = calibration(elecArray, maxStimAmp, maxForce);

%% Stimulate 
while True
    pwFES = read(u2,buffer,"double");
    writeline(bt,strcat("freq ",num2str(200)));
    cmd = generate_command(elecArray, [stimAmp stimAmp stimAmp], [pwFES], elecname);
    writeline(bt,cmd)
    writeline(bt,strcat("stim ",elecname));
end


