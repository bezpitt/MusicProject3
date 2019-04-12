classdef objList% Creates an array of notes
    properties
        arrayNotes = objNote.empty;%Sets default array to be empty
    end
    
    methods
        function obj = objList(noteMatrix)
            for k = 1:size(noteMatrix,1)
                obj.arrayNotes(k) = objNote(...
                    'equal', ...                %temperament - MIDI uses equal
                    'C', ...                    %key (always C)
                    noteMatrix(k,1), ...   %startTime
                    noteMatrix(k,2), ...   %endTime
                    noteMatrix(k,3), ...   %noteNumber
                    .05*noteMatrix(k,4)/127);      %amplitude
                    noteMatrix(k,5), ...   %instrument
            end
        end
    end
end
