function [mdl] = calibration(nElec, stimAmpM, forceMax, modelStructure, bluetoothdev,u2)
%CALIBRATION Collects input output data and identifies hammerstein model 
%   Detailed explanation goes here

%% Start recording for calibration
% Ensure real-time kernell is installed
u1 = udpport("LocalPort",12384) %increase by one if error
u2 = udpport("LocalPort",22385) %increase by one if error

buffer = 1000;
open 'calibrationSim'
bt = bluetoothdev
elecname = "testname1"

nTrials = 4;


%% Pulses 

% Start stim for calibration
for i = 1:length(nElec)
    set_param('calibrationSim','SimulationCommand','start')
    for j = 1:nTrials
        for k = 100:50:400      % FES pulse width 
            force = read(u2,buffer,"double");
            stimAmp = stimAmpM;
            display(k)
    %       b = uint8(abs(a(1))*stimCalibration)
            if force(buffer) < forceMax
                display('stim on') 
                writeline(bt,strcat("freq ",num2str(200)));
                cmd = generate_command([nElec(i)], [stimAmp], [k], elecname)
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                write(u1,k,"double","LocalHost",5000);
            else
                forceMax = force(buffer)
                stimAmp = 0;
                cmd = generate_command([nElec(i)], [stimAmp], [k], elecname)
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                writeline(bt,strcat("stim off"));
                write(u1,k,"double","LocalHost",5000);
                break;
            end
            pause(3) 
            display('stim off') 
            stimAmp = 0;
            writeline(bt,strcat("freq ",num2str(200)));
            cmd = generate_command([nElec(i)], [stimAmp], [k], elecname);
            writeline(bt,cmd)
            writeline(bt,strcat("stim ",elecname));
            write(u1,0,"double","LocalHost",5000);
            pause(3)
        end
    end
    set_param('calibrationSim','SimulationCommand','stop')
    filename = sprintf('calibrationRecording_%s', datestr(now,'mm-dd-yyyy HH-MM'));
    pause(1)
    calibrationRecording = evalin('base', 'calibrationRecording');
    save(filename, 'calibrationRecording') 
    disp('Identifying model, please wait...')
    % Divide data for identification and validation
    halfIdx = ceil(size(calibrationRecording.time,1)/2);
    
    stimAmpID = calibrationRecording.data(1:halfIdx,2);
    gripForceID = smoothdata(calibrationRecording.data(1:halfIdx,1), 'SmoothingFactor', 0.03');
%     
%     stimAmpV = calibrationRecording.data(halfIdx+1:end,2);
%     gripForceV = smoothdata(calibrationRecording.data(halfIdx+1:end,1), 'SmoothingFactor', 0.03');
    mdl{i}= nlhw(iddata(stimAmpID, gripForceID, 0.001), modelStructure); 
    disp('Model Identified')
    disp('Trial: ')
    disp(i)
end


end

