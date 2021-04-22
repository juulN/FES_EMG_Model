function [selectedElecs] = selectElec(bluetoothdev, maxStimAmp)
%selectElect Try out all electrodes and select the ones you want to use
%   Detailed explanation goes here

%% Start recording for calibration
% Ensure real-time kernell is installed
% u1 = udpport("LocalPort",12386) %increase by one if error
% u2 = udpport("LocalPort",22387) %increase by one if error

% buffer = 1000;
% open 'calibrationSim'
bt = bluetoothdev
elecname = "testname1"


writeline(bt, "sdcard rm default/test/ve5.ptn ")
writeline(bt, "sdcard cat > default/test/ve5.ptn ")
writeline(bt, "sdcard ed default/test/ve5.ptn CONST CONST R 100 100 1000 ") % 

%% Test electrodes 
selectedElecs = []; 
% Start stim for calibration
for i = 1:15
    if i == 2   % skip 2 bc anode
        continue
    end
    nextElec = false;
    while ~nextElec
        disp(['Electrode n: ', num2str(i)])
        stimAmp = input('Stim amplitude: ')
        while stimAmp > maxStimAmp || stimAmp < 0
            stimAmp = input('Please enter valid stim amplitude: ')
        end
        stimPW = input('Stim pulsewidth: ')
        while stimPW > 400 || stimPW < 100
            stimPW = input('Please enter valid stim pulsewidth: ')
        end
        
        disp('stim on') 

        cmd = generate_command([i], [stimAmp], [stimPW], elecname); 
        writeline(bt,strcat("freq ",num2str(200)));
        writeline(bt,cmd)
        writeline(bt,strcat("stim ",elecname));
 
        pause(1) 
        disp('stim off') 
        stimAmp = 0;
        writeline(bt,strcat("freq ",num2str(200)));
        cmd = generate_command([i], [stimAmp], [stimPW], elecname);
        writeline(bt,cmd)
        writeline(bt,strcat("stim ",elecname));
        
        selectElec = input('Select this electrode? (y/n): ', 's')
        if selectElec == 'y'
            nextElec = true; 
            selectedElecs = cat(2, selectedElecs, i) 
        else 
            continueElec = input('Try electrode again? (y/n): ', 's')
            if continueElec == 'n'
                nextElec = true; 
            end
        end
        
        pause(1)
   end
    

end


end

