
%% Resting-State Concurrent TMS-fMRI Protocol %%
% Written by Yasmine Bassil
% Utilizing base functions from MagVenture TMS manipulation script


%% Initialization

% Adding the path that the MagVenture TMS script sits in
% Make sure to change this based on what computer you're on
addpath('/Users/navteam/Documents/YB');

fprintf("Welcome to Yasmine's rs-TMS-fMRI control code.\n");
fprintf(">>> Initializing ...\n");

% Setting up variables
amp = 30; %stimulator amplitude
TR = 1.5; % scanner TR in seconds
delay = .15; % TR-delay between volumes in seconds
blocks = 8; % setting number of total blocks (rest + TMS)

% Opening serial port COM3
fprintf("Opening serial port.");
s = TMS('Open');

% Enabling stimulator
TMS('Enable', s)

% Getting status of machine
fprintf("Getting stimulator status.");
TMS('Status',s);

% Setting amplitude
TMS('Amplitude', s, amp)


%% Set-Up

% Setting up counters
ttl_count = 0;
j = 0;
catch_trials = [0, 1, 2];

% Calculating wait variable
wait = TR + (delay/2);

% Ensuring that the user clicks on the command window for input to be read
prompt = "Ready to continue? [y/n]\n";
txt = input(prompt,"s");

% Continuing if y was pressed
if txt == "y"
    fprintf("Waiting for TTL ...\n");
    while j < blocks
        waitforbuttonpress
        figure(gcf)
        p = get(gcf, 'CurrentCharacter');
        fprintf(p + " received."); % displays the character that was pressed
        ttl_count = ttl_count + 1; % advancing ttl pulse counter
        fprintf("Total TTL: " + ttl_count + ". ");
        fprintf('Timestamp: %s\n', datestr(now,'HH:MM:SS.FFF'));
        if rem(ttl_count,15) == 0
            count = 0;
            trials = ones(1,7);
            pick = randsample(catch_trials, 1);
            trials(1:pick) = 0;
            trials = trials(randperm(length(trials)));
            fprintf(">>> (TMS-fMRI) Waiting for TTL ...\n");
            for i = 1:length(trials)
                if trials(i) == 0
                    waitforbuttonpress
                    figure(gcf)
                    p = get(gcf, 'CurrentCharacter');
                    fprintf(">>> " + p + " received. "); % displays the character that was pressed
                    count = count + 1; % advancing ttl pulse counter
                    fprintf("Total TTL: " + count + ". ");
                    fprintf('Timestamp: %s\n', datestr(now,'HH:MM:SS.FFF'));
                elseif trials(i) == 1
                    waitforbuttonpress
                    p = get(gcf, 'CurrentCharacter');
                    fprintf(">>> " + p + " received. "); % displays the character that was pressed
                    count = count + 1;
                    fprintf("Total TTL: " + count + ". ");
                    fprintf('Timestamp: %s\n', datestr(now,'HH:MM:SS.FFF'));
                    WaitSecs(wait);
                    TMS('Single', s)
                    fprintf("PULSE! Total TMS: " + count + ". ");
                    fprintf('Timestamp: %s\n', datestr(now,'HH:MM:SS.FFF'));
                    % break if counter is greater than 8
                else
                continue
                end
            end
            j = j + 1;
        end
    end
elseif txt == "n"
    fprintf("End of session.\n");
else
    fprintf("ERROR: please enter a y or n.\n");
    txt = input(prompt,"s");
end


% THINGS TO DO 
% code catch trials
% look up how we know when scanner starts & timestamp from scanner computer
% ask Katelyn/other ppl from Jenni's lab about timing delays
