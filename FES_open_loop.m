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
%% Select elecs
maxAmp = 12;
elecArray = selectElec(bt, maxAmp)
%% Set parameters/initialise model
buffer = 1000; % Buffer for?? 
% elecArray = [11, 15, 13]; % Electrode number for each finger 
elecArray = [15];
h_mdl_struct = idnlhw([2 3 1], 'pwlinear', []); 

%% Identification of model for each electrode
maxStimAmp = 8;
maxForce = 0.2; 

h_mdls = calibration(elecArray, maxStimAmp, maxForce,h_mdl_struct, bt);

% T1 = load('FES_force_AY_21_03_11_1.mat');
% stimAmpID = T1.ans.data(1:408024,2);
% gripForceID = smoothdata(T1.ans.data(1:408024,1), 'SmoothingFactor', 0.03);
% 
% stimAmpV = T1.ans.data(408024:end,2);
% gripForceV = smoothdata(T1.ans.data(408024:end,1), 'SmoothingFactor', 0.03);
% 
% %
% h_mdls{1} = nlhw(iddata(stimAmpID, gripForceID, 0.001), H_mdl); 
% h_mdls{2} = nlhw(iddata(stimAmpID, gripForceID, 0.001), H_mdl); 
% h_mdls{3} = nlhw(iddata(stimAmpID, gripForceID, 0.001), H_mdl); 
% plot(h_mdls{1})


%% Stimulate 
clear u2
% writeline(bt, "sdcard rm default/test/ve5.ptn ")
% writeline(bt, "sdcard cat > default/test/ve5.ptn ")
% writeline(bt, "sdcard ed default/test/ve5.ptn CONST CONST R 100 100 500 ") % 

testname = "testname1"; 
% Anode is 2, select others 
% elecArray = [16, 1, 5];
% amplitude =6; 
velecnumber = 10;
% maxStimAmp = 9;
elecArray = [11, 15, 13]; % Electrode number for each finger 

stimAmp = maxStimAmp; 
elecname = "testname1"
u2 = udpport("LocalPort",22392) %increase by one if error


open 'openloopFEScontrollerSim'
set_param('openloopFEScontrollerSim','SimulationCommand','start')



writeline(bt,strcat("freq ",num2str(200)));
cmd = generate_command(elecArray, [0 0 0], [300 300 300], elecname, velecnumber);
writeline(bt,cmd)
writeline(bt,strcat("stim ",elecname));

c = clock;
clockPrev = c(4)*3600+c(5)*60+c(6);
while true
    pwFES = read(u2,999,"double");  % ensure buffer is multiple of number of electrodes used 
    c = clock;
    clockNew = c(4)*3600+c(5)*60+c(6); 
    if clockNew > clockPrev+1      %Send stim every period
        round(pwFES(end-2:end))
        cmd = generate_command(elecArray, [stimAmp stimAmp stimAmp], round(pwFES(end-2:end)), elecname, velecnumber);
        writeline(bt,cmd)
        clockPrev = clockNew; 
    end
end
set_param('openloopFEScontrollerSim','SimulationCommand','stop')

save('openloopT3', 'controllerData')