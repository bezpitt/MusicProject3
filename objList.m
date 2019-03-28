% Creates an array of notes

classdef objList
    properties
        Notearray = objList.empty;%Sets default array to be empty
    end
    
    methods
        function obj = objList(Matrices)
            Length = size(Matrices);
            Length = Length(2);
            for k = 1:size(noteMatrix,1)
                obj.Notearray(k) = objNote(...
                    noteMatrix(k,1), ...   %noteNumber
                    noteMatrix(k,2), ...   %instrument
                    'equal', ...                %temperament - MIDI uses equal
                    'C', ...                    %key - C used, not relevant, but kept to maintain functionality
                    noteMatrix(k,3), ...   %startTime
                    noteMatrix(k,4), ...   %endTime
                    noteMatrix(k,4)./127);      %amplitude
                
            end
        end
    end
end
