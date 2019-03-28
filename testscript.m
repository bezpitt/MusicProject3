% This is a simple test script to demonstrate all parts of HW #1

close all                                                                               % Close all open windows
clear classes                                                                           % Clear the objects in memory
format compact                                                                          % reduce white space
dbstop if error                                                                         % add dynamic break point

% PROGRAM CONSTANTS
constants                              = confConstants;
constants.BufferSize                   = 882;                                                    % Samples
constants.SamplingRate                 = 44100;                                                  % Samples per Second
constants.QueueDuration                = 0.1;                                                    % Seconds - Sets the latency in the objects
constants.TimePerBuffer                = constants.BufferSize / constants.SamplingRate;          % Seconds;

oscParams                              =confOsc;
oscParams.oscType                      = 'sine';
oscParams.oscAmpEnv.StartPoint         = 0;
oscParams.oscAmpEnv.ReleasePoint       = Inf;   % Time to release the note
oscParams.oscAmpEnv.AttackTime         = .125;%.02;  %Attack time in seconds
oscParams.oscAmpEnv.DecayTime          = .125;%.01;  %Decay time in seconds
oscParams.oscAmpEnv.SustainLevel       = .5;%0.7;  % Sustain level
oscParams.oscAmpEnv.ReleaseTime        = .25;%.05;  % Time to release from sustain to zero


% Play the scales


majorScaleJust=objScale('major',60,'just','C',120);
tmp=playAudio(majorScaleJust,oscParams,constants);

majorScaleEqual=objScale('major',60,'equal','C',120);
playAudio(majorScaleEqual,oscParams,constants);

minorScaleJust=objScale('minor',60,'just','C',120);
playAudio(minorScaleJust,oscParams,constants);

minorScaleEqual=objScale('minor',60,'equal','C',120);
playAudio(minorScaleEqual,oscParams,constants);


% Play the chords
majorChordJust=objChord('major',60,'just','C',120);
playAudio(majorChordJust,oscParams,constants);
%
majorChordEqual=objChord('major',60,'equal','C',120);
playAudio(majorChordEqual,oscParams,constants);
%
minorChordJust=objChord('minor',60,'just','C',120);
playAudio(majorChordJust,oscParams,constants);

minorChordEqual=objChord('minor',60,'equal','C',120);
playAudio(majorChordEqual,oscParams,constants);

