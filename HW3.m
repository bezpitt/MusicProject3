clear all
tic
FILE = fopen('furelise.mid', 'r');
Mid =  fread(FILE);
file_length = length(Mid);
chunk_length = 0;
endtrack = 1;
cmd_cnter = 1;
Cmnd_Matrix = [0 0 0 0 0];
trk_cntr = 1;

%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%

if( (Mid(1) == 77) && (Mid(2) == 84) && (Mid(3) == 104) && (Mid(4) == 100) )%If valid Mthd
    num_tracks = Mid(11)*16 + Mid(12);
    pulses_per_quarter = Mid(13)*16 + Mid(14);
    k = 15;
    while k <= file_length
        %This while loop is meant to go through the entire file
        if( (Mid(k) == 77) && (Mid(k+1) == 84) && (Mid(k+2) == 114) && (Mid(k+3) == 107) )%If valid Mtrk
            %We are now in a track
            k = k + 4;%At 19 if first track
            chunk_length = Mid(k)*4096 + Mid(k+1)*256 + Mid(k+2)*16 + Mid(k+3);
            k = k + 4;%24
            if (Mid(k) == 0) && (Mid(k+1) == 255)%This if statement ignores timing of initial special commands
                k = k+1;
            end
            if Mid(k) == 255%Special Command
                k = k+1;
                while 1
                    switch Mid(k)
                        case 88
                            endtrack = 0;
                            k = k+2;
                            numerator = Mid(k);
                            k = k+1;
                            denominator = 2.^Mid(k);
                            k = k+1;
                            clks_per_click = Mid(k);
                            k = k+1;
                            per_quarter = Mid(k);
                            k = k+1;%Goes to next command
                        case 81
                            endtrack = 0;
                            k = k+2;
                            micros_per_quarter = Mid(k)*2^16 + Mid(k+1)*2^8 + Mid(k+2);%This line is fucked
                            k=k+3;%Goes to next command
                        case 3%Name of track. We don't care so we skip it
                            while Mid(k) ~= 0
                                k = k+1;
                            end
                        case 47%end track
                            k = k+1;
                            endtrack = 1;%A flag used for control
                            break
                        case 0
                            if Mid(k+1) ~= 255%This would indicate we are done with special commands
                                endtrack = 0;
                                break
                            else
                                k = k+2;%Skip to what the special command is
                            end
                        otherwise%Some command I don't care about
                            break
                    end
                end
            end
        if endtrack == 0
            Cmnd_Matrix = zeros(chunk_length,5);%An overestimate of Matrix size but we'll get rid of empty rows later
            last_time = 0;
            %{
            while Mid(k) == 0%This is is in case my numbers from before didn't add up exactly to be at the
                %right starting position
                 k = k +1;   
            end
            %}
            Patch_tester = dec2bin(Mid(k),8);
            if Patch_tester(1:4) == '1100'%This skips patches
                k = k+2;
            end
            while 1%Chunk length provides a ridiculous uper bound on count, but I like it better than while 1
                %This while loop is meant to go through the entire track
                %We are now in the meat of the track
                [time,to_end_of_time_sig] = calculate_time(Mid(k:end));
                last_time = last_time + time;%Neccessary because we need to add up the times as we go
                Cmnd_Matrix(cmd_cnter,1) = last_time;%Time is the first column of the Cmnd_Matrix
                k = k+to_end_of_time_sig;
                %while 1
                    %This while loop is meant to go through the entire
                    %command
                    binary_Mid = dec2bin(Mid(k),8);
                    if binary_Mid(1) == '1'%if command
                        switch binary_Mid(2:4)
                            case '000'%Note off
                                %two bytes after
                                 Cmnd_Matrix(cmd_cnter,2) = 0;
                                 last_command = 0;
                                 k = k+1;
                                 Cmnd_Matrix(cmd_cnter,3) = Mid(k);%Third column is the note
                                 k = k+1;
                                 Cmnd_Matrix(cmd_cnter,4) = Mid(k);%Fourth column is the velocity
                                 k = k+1;
                            case '001'%Note on
                                %two bytes after
                                 Cmnd_Matrix(cmd_cnter,2) = 1;
                                 last_command = 1;
                                 k = k+1;
                                 Cmnd_Matrix(cmd_cnter,3) = Mid(k);%Third column is the note
                                 k = k+1;
                                 Cmnd_Matrix(cmd_cnter,4) = Mid(k);%Fourth column is the velocity
                                 k = k+1;
                            case '010'%aftertouch
                                %two bytes after
                                k = k+3;
                                last_command = 3;
                            case '011'%Control change
                                %two bytes after
                                k = k+3;
                                last_command = 3;
                            case '100'%Program/Patch Change
                                %1 byte after
                                k = k+2;
                                last_command = 2;
                            case '101'%Channel Pressure
                                %1 byte after
                                k = k+2;
                                last_command = 2;
                            case '110'%Pitch Bend
                                %Two bytes after
                                k = k+3;
                                last_command = 3;
                            case '111'
                                switch binary_Mid(5:8)
                                    case '0000'%system exclusive
                                        %ignore
                                        k = k+1;
                                    case '0001'%Time Quarter frame
                                        %1 byte after
                                        k = k+2;
                                    case '0010'
                                        %2 bytes after
                                        k = k+3;
                                    case '0011'
                                        %one byte after
                                        k = k+2;
                                    case '1111'%Track over
                                        k = k+1;
                                        binary_Mid = dec2bin(Mid(k),8);
                                        if binary_Mid == '00101111'%Track over
                                            %i don't know why there's a
                                            %squiggly here but this line
                                            %works
                                            endtrack = 1;
                                            k = k+1;
                                            break
                                        end
                                    otherwise%Just skip this one byte
                                        k = k+1;
                                end
                        end
                    else%if running command
                        switch last_command
                            case 0
                                Cmnd_Matrix(cmd_cnter,2) = 0;
                                 k = k+1;
                                 Cmnd_Matrix(cmd_cnter,3) = Mid(k);%Third column is the note
                                 k = k+1;
                                 Cmnd_Matrix(cmd_cnter,4) = Mid(k);%Fourth column is the velocity
                                 k = k+1;
                            case 1
                                Cmnd_Matrix(cmd_cnter,2) = 1;
                                k = k+1;
                                Cmnd_Matrix(cmd_cnter,3) = Mid(k);%Third column is the note
                                k = k+1;
                                Cmnd_Matrix(cmd_cnter,4) = Mid(k);%Fourth column is the velocity
                                k = k+1;
                            case 2
                                k = k+2;
                            case 3
                                k = k+3;
                        end
                    end
                    if endtrack == 1%Breaks from track
                        endtrack = 0;
                        break
                    end
                %end
                cmd_cnter = cmd_cnter+1;
            end
                        
        end
        if endtrack == 1
            cmd_cnter = 1;
            if trk_cntr <= 4
                Cmnd_Matrix(:,5) = trk_cntr-1;
            else
                Cmnd_Matrix(:,5) = 1;%Default instrument
            end
            final_Matrices{trk_cntr} = Cmnd_Matrix;
            endtrack = 0;
            trk_cntr = trk_cntr + 1;%This is actually one more than the amount of tracks because indexing at 1 and it runs at beginning without track
        end
        k = k+1;%If all else fails, at least increment the counter
        end
    end
end
%Parsing worked for row-row now let's play some music
% [time on/off note pressure instrument]
final_Matrices(1) = [];
Length = length(final_Matrices);

%This for loop gets rid of empty rows. Since 0 is a subaudible frequency,
%it doesn't matter that we may potentially remove those notes
%Also reformats to start and end times
New_Matrices = [];
for k = 1:Length%Goes through all matrices in final_Matrices
%k = 3;
    new = 1;
    Current_Matrix = final_Matrices{k};
    Current_Matrix = Current_Matrix(Current_Matrix(:,3) ~= 0,:);
    curlength = length(Current_Matrix);
    New_Matrix = zeros(1,5);
    for h = 1:curlength%Sweep through Current_matrix looking for notes on
        if Current_Matrix(h,2) == 1%if note on
            for p = h:length(Current_Matrix)%Sweep until note appears again
                if Current_Matrix(h,3) == Current_Matrix(p,3)
                    if (Current_Matrix(p,4)  == 0) || (Current_Matrix(p,2)  == 0)
                        Current_Matrix(h,2) = Current_Matrix(p,1);%Puts end time in column 2
                        New_Matrix(new,:) = Current_Matrix(h,:);
                        new = new + 1;
                        break;%Breaks out of p loop
                    end
                end
            end
        end
    end
    %New_Matrices = New_Matrix
    New_Matrices = [New_Matrices; New_Matrix];
end
New_Matrices = sortrows(New_Matrices);
%Have to do time conversion
New_Matrices(:,1:2) = New_Matrices(:,1:2)* 10^-6 * (micros_per_quarter/pulses_per_quarter);%should be 10^-6
%micros per quarter is wrong
noteObjArray = objList(New_Matrices);
toc
playAudio(noteObjArray, oscParams, constants);
% [on_time off_time note pressure instrument]

%Length = Length(2);
%final_Matrices{1} = [];
%{
for k = 2:Length%First is empty
    Here = final_Matrices{k};
    for inc = 1:size(Here,1)
        if sum(Here(inc,1:4)) == 0
            delete_vector = 
    for inc = 
        
    end
    New_Matrix = 
    cur_matrix = final_Matrices(k);
    final_Matrices(k) = sortrows(final_Matrices(k),
end
%}


