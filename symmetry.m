function [routine] = symmetry

p = mfilename('fullpath');
[p,~,~] = fileparts(p);

% Bin
bin = [p filesep 'bin'];
addpath(bin);

flags = {
    'debug',false;
    'verbose',true;
    'path',p;
    'input','stim';
    'output','data';
    'io','io';    
    };

client = Client(flags);
client.bootstrap;

% plugin = PTB(client.get_defaults_value('debug'),client.get_defaults_value('verbose'));
plugin = PTB(~client.get_defaults_value('debug'),client.get_defaults_value('verbose'));

if client.get_defaults_value('debug')
    [~,~,~,debug_exec] = paradigm(client,plugin);
    debug_exec();
else
    plugin.open;
    
    % Start of loop
    % for iterations
    
    [t,kill,routine] = paradigm(client,plugin);
    plugin.initPres;
    KbName('UnifyKeyNames');
    client.setUpOutputStream(client.get_defaults_value('id')); % Temp file
    
    % KB press
    % Trigger
    % GetSecs;
    KbStrokeWait;
    
    client.startThreads;
    start(t);

    pause(1) % temp
    while strcmp('on', get(t,'Running')) % While timer is running
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if find(keyCode)==KbName('Escape')
                kill(t)
                break;
            end
        end
    end

    plugin.endPres;
    client.stopThreads;
    % End of loop
    
    client.cleanUpIO;
end

disp('debug');
    
% % Initializing
% stimonset = [];

% % Task
% RT = 0;
% Hit = 0;
% Miss = 0;

% % Calculating pixelsPerDegree
% monitorWidth   = 48;   % horizontal dimension of viewable screen (cm)
% viewingDistance      = 60;   % viewing distance (cm)
%
% % Fixation setup
% fixationPointRadius = 0.15;
% [ windowCenter(1), windowCenter(2) ] = RectCenter( windowRectangle );
% pixelsPerDegree = ( pi / 360 ) * ( windowRectangle(3) - windowRectangle(1) ) ...
%                     / atan(   ( monitorWidth / 2 ) / viewingDistance  );     % pixels per degree
% params.display.fixationPointCoordinates = [ (  windowCenter - ( fixationPointRadius * pixelsPerDegree )  ) ...
%                 (  windowCenter + ( fixationPointRadius * pixelsPerDegree )  ) ];

%     if keyIsDown
%         if keyCode(escapeKey)
%
%             stop(t)
%             disp('User Cancelled')
%
%         elseif keyCode(cKey)
%
%             RT =  sec - get(t,'UserData');
%
%             % If there was a change at this task (Hit)
%             if pres_cell{get(t,'TasksExecuted') + 1, 4} % Accounting for initial flip
%                 Hit = 1;
%             end % End if: pres_cell{stimind, 4}
%
%             KbReleaseWait; % Wait for release
%
%         end % End if: keyCode(escapeKey)
%     end % End if: keyIsDown
%
% end % End while: strcmp('on', get(t, 'Running'))

end % End primary function