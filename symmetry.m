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

plugin = PTB(client.get_defaults_value('debug'),client.get_defaults_value('verbose'));
% plugin = PTB(~client.get_defaults_value('debug'),client.get_defaults_value('verbose'));
KbName('UnifyKeyNames');
        
if client.get_defaults_value('debug')
    [~,~,setOutput,~,registerRoutine,debug_exec] = paradigm(client,plugin);
    routine = registerRoutine();
    setOutput(int2str(1));
    
    client.startThreads;
    debug_exec();
    client.stopThreads;
    client.cleanUpIO;
    client.mainCloseFileCb();
else
    
    [t,kill,setOutput,exp,registerRoutine] = paradigm(client,plugin);
    abort = 0;
    keys = plugin.keyGet;
    plugin.initPres;
    
    routine = cell([1 exp.run]);
    % Loop runs
    for i = 1:exp.run
        
        routine{i} = registerRoutine();
        setOutput(int2str(i));
        tExecuted = 0;
        
        plugin.drawtxt('Preparing experiment. Please wait.');
        client.startThreads;
        
        if client.get_defaults_value('verbose')
            fprintf('%s...\n','Run index');
            fprintf('\t%d\n',i);
            fprintf('%s.\n','Ready');
        end
        
        % Experimenter press
        plugin.drawtxt('Experimenter press spacebar.');
        RestrictKeysForKbCheck(keys.spacekey);
        KbStrokeWait;
        % Trigger
        if exp.trig
            plugin.drawtxt('Waiting for trigger');
            RestrictKeysForKbCheck(keys.tkey);
            KbStrokeWait;
        else
            plugin.drawtxt('Waiting for start');
            RestrictKeysForKbCheck(keys.spacekey);
            KbStrokeWait;
            plugin.drawtxt('Waiting for start.');
            % # of dummy scans = 1 + quotient[ 3/TR(in seconds) ] if no iPAT.
            disDaq = exp.tr * (1 + floor(3/exp.tr)) + .75; % (s)
            WaitSecs(disDaq);
        end
        
        RestrictKeysForKbCheck([keys.esckey keys.akey]);
        
        start(t);
        
        while strcmp('on', get(t,'Running')) % While timer is running
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                if find(keyCode)==keys.esckey
                    kill(t);
                    abort = 1;
                    break;
                % Detect if valid key is pressed (b or c using grips)
                elseif ( find(keyCode)==keys.bkey ) || ( find(keyCode)==keys.ckey ) )
                    if tExecuted ~= get(t,'TasksExecuted')
                        tExecuted = get(t,'TasksExecuted');
                        client.response = true;
                        if client.get_defaults_value('verbose')
                            fprintf('%s...\n','Behavioral response detected, task');
                            fprintf('\t%d\n',tExecuted);
                        end
                    end
                end
            end
        end
        
        client.stopThreads;
        client.cleanUpIO;
        client.mainCloseFileCb();
        
        if abort
            break;
        end
        
        RestrictKeysForKbCheck([]);
    end
    delete(t);
    plugin.endPres;
end

end % End primary function