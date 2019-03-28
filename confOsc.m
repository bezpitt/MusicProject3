
%classdef objSynthSineNote < matlab.System
classdef confOsc < handle
    properties
        % Defaults
        oscType                  = 'sine';
        oscHarms                 = 1;
        oscAmpEnv                = confEnv;
        oscFiltEnv               = confEnv;
        oscFreqEnv               = confEnv;
    end
    %properties (GetAccess = private)
    
    methods
        function obj = confOsc(varargin)
            if nargin > 0
                obj.currentTime=0;

                if nargin >= 5
                    obj.oscFreqEnv=varargin{5};
                end
                if nargin >= 4
                    obj.oscFiltEnv=varargin{4};
                end
                if nargin >= 3
                    obj.oscAmpEnv=varargin{3};
                end
                if nargin >= 2
                    oscHarms = varargin{2}
                end
                if nargin >=1
                    obj.oscType=varargin{1};
                end
                
            end

        end
        
    end
    
    %methods (Access = protected)
    %function audio = stepImpl(~)
    methods
        function env = advance(obj)
            
        end
    end
end



