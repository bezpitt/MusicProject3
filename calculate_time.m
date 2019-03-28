function [total_time,end_k] = calculate_time(Midi)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    k = 1;
    time_vec = [];
    while 1
        binary_time = dec2bin(Midi(k),8);
        time_vec = [time_vec binary_time(2:end)];
        if Midi(k) < 128
            break
        end
        k = k+1;
    end
    first = join(time_vec);
    total_time = bin2dec(first);
    end_k = k;
end

