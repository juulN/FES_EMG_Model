%% FES controller 
% Open/closed loop FES control 

clc; clear all; close all;
pnet('closeall')

%% **************** Connect FES device ************************************
% Set up Bluetooth connection with Technalia FES device
clear bt
bt = bluetooth("0016A474B78F", 1);  %MAC address of device 
writeline(bt,"iam DESKTOP");
writeline(bt,"battery ? ");
writeline(bt,"elec 1 *pads_qty 16");

elecname = "testname1";

% Write new stim file (last char of string not transmitted -> add space at end of string)
writeline(bt, "sdcard rm default/test/ve5.ptn ")
writeline(bt, "sdcard cat > default/test/ve5.ptn ")
writeline(bt, "sdcard ed default/test/ve5.ptn CONST CONST R 100 100 3000 ") % 
                                     % %pulsewith 
                             % time(us)(1ms -3000ms)
                      % %amplitude 
%% Set parameters/initialise model
elecArray = [1];   % Currently models and scripts set to only stim with one electrode!
inputNL = pwlinear('NumberOfUnits', 11);
h_mdl_struct = idnlhw([3 4 1], inputNL, []); 
maxStimAmp = 9;
maxForce = 1; 
                      
%% **************** Select stimulation electrode - do not run **************************
% Call function that cycles through all electrodes to find the one with the
% best/most comfortable grip force output
% elecArray = selectElec(bt, maxStimAmp)
% maxStimAmp = input('Maximum comfortable stimulation amplitude: ');
% 
% while maxStimAmp > 20 || maxStimAmp < 0
%             maxStimAmp = input('Please enter valid stim amplitude: ');
% end

%% ***************** Model identification *********************************
% Identification of model for each electrode
h_mdls = calibration(elecArray, maxStimAmp, maxForce,h_mdl_struct, bt);

%% ***************** Experiment 1 Settings - run this in new Matlab Instance (MI2) *********************************
% Experiment Settings
clear all
load('maxF'); % Change before running!
maxF = forceRead;
Kp = 15000;
Ki = 10000;
Kd = 0; 
bias = 0;
load('controlpattern.mat')
% load('controlpatternVOL.mat')
load('mdl')
h_mdls = mdl;
%Then open and start FESControllerSim
open 'FEScontrollerSim'
set_param('FEScontrollerSim','SimulationCommand','start')
%% ***************** Experiment 2 Settings - run this in new Matlab Instance (MI2) *********************************
% Experiment Settings
clear all
load('maxF'); % Change before running!
maxF = forceRead;
Kp = 15000;
Ki = 10000;
Kd = 0; 
bias = 0;
% load('controlpattern.mat')
load('controlpatternVOL.mat')
load('mdl')
h_mdls = mdl;
%Then open and start FESControllerSim
open 'FEScontrollerSim'
set_param('FEScontrollerSim','SimulationCommand','start')

%% ******************** Controller - Run in MI1 after runnning Simulink in MI2 ***************************************
% Select appropriate simuli nk model (openloop, PID)
clear u2
u2 = udpport("LocalPort",22392); % open udp for FES pw from simulink, clear port if error

velecnumber = 11;           % Choose velec that has not been defined, do not select 2 bc it is the anode 
% maxStimAmp = 9;
stimAmp = maxStimAmp;
% elecArray = [1];

% eval('!matlab  -nodesktop -nosplash -r "RDAtoSimulink(450)" &') % start tcp for emg recording

% open 'openloopFEScontrollerSim'
% set_param('openloopFEScontrollerSim','SimulationCommand','start')
% open 'PID_FEScontrollerSim'
% set_param('PID_FEScontrollerSim','SimulationCommand','start')

writeline(bt,strcat("freq ",num2str(20), " "));      %Set stim frequency
cmd = generate_command(elecArray, [0], [300], elecname, velecnumber); % Params for start stimulation
writeline(bt,cmd)                               %Start stimulation
writeline(bt,strcat("stim on "));               %Start stimulation 

c = clock;
clockPrev = c(4)*3600+c(5)*60+c(6);
clockStart = clockPrev;
clockNew = clockPrev;

while clockNew<clockStart+590
%     disp('before read');
    pwFES = read(u2,1,"double");  % ensure buffer is multiple of number of electrodes used 
%     disp('after read');
    c = clock;
    clockNew = c(4)*3600+c(5)*60+c(6);
    if clockNew > clockPrev+0.05      %Send stim every 0.01s
%         disp(pwFES(end))`
        cmd = generate_command(elecArray, [stimAmp], round(pwFES(end)), elecname, velecnumber);
        writeline(bt,cmd)
        clockPrev = clockNew; 
    end
end

cmd = generate_command(elecArray, [1], 100, 'testname1', 11); % Params for start stimulation
writeline(bt,cmd) 
writeline(bt,"stim off ")
%% ****************** Save data *******************************************
% press CTRL+C to stop early
cmd = generate_command(elecArray, [1], 100, 'testname1', 11); % Params for start stimulation
writeline(bt,cmd) 
writeline(bt,"stim off ")

%%
% set_param('openloopFEScontrollerSim','SimulationCommand','stop')
% set_param('PID_FEScontrollerSim','SimulationCommand','stop')

filename = sprintf('OpenLoop_%s', datestr(now,'mm-dd-yyyy HH-MM'));
% filename = sprintf('PID_%s', datestr(now,'mm-dd-yyyy HH-MM'));

save(filename, 'controllerData')
