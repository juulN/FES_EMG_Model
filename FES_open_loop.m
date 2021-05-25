%% FES controller 
% Open/closed loop FES control 

clc; clear all; close all;
pnet('closeall')

%% **************** Connect FES device ************************************
% Set up Bluetooth connection with Technalia FES device
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
elecArray = [15];   % Currently models and scripts set to only stim with one electrode!
h_mdl_struct = idnlhw([2 3 1], 'pwlinear', []); 
maxStimAmp = 8;
maxForce = 0.2; 
                      
%% **************** Select stimulation electrode **************************
% Call function that cycles through all electrodes to find the one with the
% best/most comfortable grip force output
elecArray = selectElec(bt, maxStimAmp)
maxStimAmp = input('Maximum comfortable stimulation amplitude: ');

while maxStimAmp > 20 || maxStimAmp < 0
            maxStimAmp = input('Please enter valid stim amplitude: ');
end

%% ***************** Model identification *********************************
% Identification of model for each electrode
h_mdls = calibration(elecArray, maxStimAmp, maxForce,h_mdl_struct, bt);

%% ******************** Controller ***************************************
% Select appropriate simulink model (openloop, PID)
clear u2
u2 = udpport("LocalPort",22392); % open udp for FES pw from simulink, clear port if error


velecnumber = 11;           % Choose velec that has not been defined, do not select 2 bc it is the anode 
stimAmp = 8; 

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
while clockNew<clockStart+400
%     disp('before read');
    pwFES = read(u2,1,"double");  % ensure buffer is multiple of number of electrodes used 
%     disp('after read');
    c = clock;
    clockNew = c(4)*3600+c(5)*60+c(6);
    if clockNew > clockPrev+0.02      %Send stim every 0.01s
%         disp(pwFES(end))
        cmd = generate_command(elecArray, [stimAmp], round(pwFES(end)), elecname, velecnumber);
        writeline(bt,cmd)
        clockPrev = clockNew; 
    end
end
%% ****************** Save data *******************************************
% press CTRL+C to stop early
writeline(bt,"stim off ")

% set_param('openloopFEScontrollerSim','SimulationCommand','stop')
% set_param('PID_FEScontrollerSim','SimulationCommand','stop')

filename = sprintf('OpenLoop_%s', datestr(now,'mm-dd-yyyy HH-MM'));
% filename = sprintf('PID_%s', datestr(now,'mm-dd-yyyy HH-MM'));

save(filename, 'controllerData')
