function t = paradigm()
% function paradigm(client,ptb)

    % % UI entry 
% prompt1 = {'Subject ID (YYMMDDffll):', 'Date (YYMMDD):'};
% dlg_title1 = 'Fill out Subject Information';    
% num_lines1 = 1;
% def1 = {'', datestr(now, 'yymmdd')}; % # of Defs = # prompt fields
% options.Resize = 'on';
% subjout = inputdlg(prompt1, dlg_title1, num_lines1, def1, options);

% % Subject data
% subj_id = subjout{1}; 
% subj_date = subjout{2};
% subj_str = [subj_id '_' subj_date];

% % Output setup
% filename = [file_dir filesep 'data' filesep subj_str '.csv'];
% fid = fopen(filename, 'a');

% Load pictures
% s = segment('testname','testpath');

% Organize

invoker = invoke();
cbk = @(obj,evt)invoker.execute;

t = timer;
set(t, 'Name', 'test', 'ExecutionMode', 'fixedRate', 'Period', 1, ...
    'StartFcn', @start_callbck, 'TimerFcn', cbk, 'TasksToExecute', 2);
%             , 'StopFcn',stop_callbck, ...
%                 'ErrorFcn', @err_callbck, 'TasksToExecute', 2, 'UserData', 1, 'StartDelay', 1);

    function start_callbck(obj,~)
        disp('started')
    end

end

