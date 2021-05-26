function [mdl] = calibration(nElec, stimAmpM, forceMax, modelStructure, bluetoothdev,u2)
%CALIBRATION Collects input output data and identifies hammerstein model 
%   Detailed explanation goes here

%% Start recording for calibration
% Ensure real-time kernell is installed
u1 = udpport("LocalPort",12386) %increase by one if error
u2 = udpport("LocalPort",22387) %increase by one if error
% u3 = udpport("LocalPort", 132)

buffer = 1000;
open 'calibrationSim'


bt = bluetoothdev
elecname = "testname1";

writeline(bt, "sdcard rm default/test/ve5.ptn ")
writeline(bt, "sdcard cat > default/test/ve5.ptn ")
writeline(bt, "sdcard ed default/test/ve5.ptn CONST CONST R 100 100 2500 ") % 
% startSimCalibration
nTrials = 10;
set_param('calibrationSim','SimulationCommand','start')
% Set time to nElec*nTrials*7*5
eval('!matlab  -nodesktop -nosplash -r "RDAtoSimulink(250)" &') % -nodesktop -nosplash
disp('Waiting for tcp connection')
pause(10)
disp('Continue')
%% Pulses

% Start stim for calibration
for i = 1:length(nElec)
    for j = 1:nTrials
%         for k = 100:50:400      % FES pulse width 
%             force = read(u2,buffer,"double");
%             stimAmp = stimAmpM;
%             disp(k)
%     %       b = uint8(abs(a(1))*stimCalibration)
%             if force(buffer) < forceMax
%                 disp('stim on') 
%                 writeline(bt,strcat("freq ",num2str(20), " "));
%                 cmd = generate_command([nElec(i)], [stimAmp], [k], elecname);
%                 writeline(bt,cmd)
%                 writeline(bt,strcat("stim ",elecname));
%                 write(u1,k,"double","LocalHost",5000);
%             else
%                 forceMax = force(buffer);
%                 stimAmp = 0;
%                 cmd = generate_command([nElec(i)], [stimAmp], [k], elecname);
%                 writeline(bt,cmd)
%                 writeline(bt,strcat("stim ",elecname));
%                 writeline(bt,strcat("stim off "));
%                 write(u1,k,"double","LocalHost",5000);
%                 break;
%             end
%             pause(3) 
%             disp('stim off') 
%             writeline(bt,strcat("stim off "));
%             write(u1,0,"double","LocalHost",5000);
%             pause(2)
%         end
        
        for k = 100:50:400      % FES pulse width 
            force = read(u2,buffer,"double");
            stimAmp = stimAmpM;
            disp(k)
    %       b = uint8(abs(a(1))*stimCalibration)
            if force(buffer) < forceMax
                disp('stim on') 
                writeline(bt,strcat("freq ",num2str(20), " "));
                cmd = generate_command([nElec(i)], [stimAmp], [k], elecname);
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                write(u1,k,"double","LocalHost",5000);
            else
                forceMax = force(buffer);
                stimAmp = 0;
                cmd = generate_command([nElec(i)], [stimAmp], [k], elecname);
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                writeline(bt,strcat("stim off "));
                write(u1,k,"double","LocalHost",5000);
                break;
            end
            pause(2.5) 
%             disp('stim off') 
%             writeline(bt,strcat("stim off "));
%             write(u1,0,"double","LocalHost",5000);
%             pause(2)
        end
        for k = 350:-50:100      % FES pulse width 
            force = read(u2,buffer,"double");
            stimAmp = stimAmpM;
            disp(k)
    %       b = uint8(abs(a(1))*stimCalibration)
            if force(buffer) < forceMax
                disp('stim on') 
                writeline(bt,strcat("freq ",num2str(20), " "));
                cmd = generate_command([nElec(i)], [stimAmp], [k], elecname);
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                write(u1,k,"double","LocalHost",5000);
            else
                forceMax = force(buffer);
                stimAmp = 0;
                cmd = generate_command([nElec(i)], [stimAmp], [k], elecname);
                writeline(bt,cmd)
                writeline(bt,strcat("stim ",elecname));
                writeline(bt,strcat("stim off "));
                write(u1,k,"double","LocalHost",5000);
                break;
            end
            pause(2.5) 
%             disp('stim off') 
%             writeline(bt,strcat("stim off "));
%             write(u1,0,"double","LocalHost",5000);
%             pause(2)
        end
        disp('stim off') 
        writeline(bt,strcat("stim off "));
        write(u1,0,"double","LocalHost",5000);
    end
    
    set_param('calibrationSim','SimulationCommand','stop')
    filename = sprintf('calibrationRecording_%s', datestr(now,'mm-dd-yyyy HH-MM'));
    pause(1)
    calibrationRecording = evalin('base', 'calibrationRecording');
    save(filename, 'calibrationRecording') 
    disp('Identifying model, please wait...')
    % Divide data for identification and validation
%     halfIdx = ceil(size(calibrationRecording.time,1)*2/3);
    
    stimAmpID = calibrationRecording.data(:,2);
    gripForceID = smoothdata(calibrationRecording.data(:,1), 'SmoothingFactor', 0.03');
    
%     stimAmpV = calibrationRecording.data(halfIdx+1:end,2);
%     gripForceV = smoothdata(calibrationRecording.data(halfIdx+1:end,1), 'SmoothingFactor', 0.03');
    mdl{i}= nlhw(iddata(stimAmpID, gripForceID, 0.001), modelStructure); 
    filename = sprintf('mdl_%s', datestr(now,'mm-dd-yyyy HH-MM'));
    save(filename,mdl);
    disp('Model Identified')

end


end

