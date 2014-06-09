function [varargout] = paradigm(Client,Plugin)

% % % UI entry 
% % % prompt1 = {'Subject ID (YYMMDDffll):', 'Date (YYMMDD):'};
% % % dlg_title1 = 'Fill out Subject Information';    
% % % num_lines1 = 1;
% % % def1 = {'', datestr(now, 'yymmdd')}; % # of Defs = # prompt fields
% % % options.Resize = 'on';
% % % subjout = inputdlg(prompt1, dlg_title1, num_lines1, def1, options);
% % 
% % % % Subject data
% % % subj_id = subjout{1}; 
% % % subj_date = subjout{2};
% % % subj_str = [subj_id '_' subj_date];
% % 
% % % % Output setup
% % % filename = [file_dir filesep 'data' filesep subj_str '.csv'];
% % % fid = fopen(filename, 'a');
% % 
% % % Load pictures
% % % s = segment('testname','testpath');

% Rules and logic
% Filenames
% pat = '1(?<group>\d{2,2})0(?<image>\d{2,2})[.](?<imagetype>\w+)';
pat = '1(?<group>\d{2,2})0(?<image>\d{2,2})';
re = @(y)regexp(y,pat,'names');
[img_names,files_n] = Client.get_image_names;
meta = cellfun(re,img_names);
data = Client.data;

% Metadata mapping
for i = 1:files_n
    [~,name] = fileparts(img_names{i});
    meta(i).name = name;
end
var_1 = '01';
var_n = unique({meta(:).group});var_n = var_n(~strcmp(var_n,var_1));

% Subdivisions, image index, and validation
var_i = {}; % push
random_within_var = true; % Missing business rule, assuming random
for i = 0:size(var_n,2)
    if i
        var_i{end+1} = find(strcmp(var_n{i},{meta(:).group}));
        if random_within_var
            var_i{end} = Shuffle(var_i{end});
        end
    else
        var_i{end+1} = find(strcmp(var_1,{meta(:).group}));
    end
    assert(length(unique({meta(var_i{end}).image})) == length({meta(var_i{end}).image}),'Image duplicates found!');
end
set_n = unique(cellfun(@length,var_i));
assert(length(set_n)==1,'Inconsistent image sets found!')

% "Optseq" e-mail, Peter Jes Kohler, pjkohler@stanford.edu
% Deprecate in future release
tempIdx1 = repmat(2:length(var_n)+1,set_n);
condOrder = tempIdx1(randperm(length(tempIdx1)));
tempIdx2 =  repmat(2:4,1,27);
jitterOrder = tempIdx2(randperm(length(tempIdx2)));
jitterOrder = jitterOrder(logical(condOrder)); % Idempotent
top_iter = condOrder;
iter_some_subvar = jitterOrder;
% Deprecate in future release

% Task
% if task
%         fix_color = {uint8([255, 0, 0]),uint8([0, 255, 0])};
%         fix_radius = 5;
%         fix_line = 2;
%         fix_p_chg = .7;
%         fix_type = {'FillOval'};
%
% To segments, out timer

% Register
inv = invoke();
for iter_index = 1:length(top_iter)
    
    % Multiple segment registration for iter_some_subvar
    data_index1 = datasample(var_i{1},iter_some_subvar(iter_index),'Replace',false);
    for i = 1:length(data_index1)
        inv.register(segment(data{data_index1(i)}),meta(data_index1(i)));
    end
    % Individual segment registration for top_iter
    data_index2 = var_i{top_iter(iter_index)}(1);
    var_i{top_iter(iter_index)}(1) = []; % pop
    inv.register(segment(data{data_index2}),meta(data_index2));
end

disp('debug')
% cbk = @(obj,evt)inv.execute;

% t = timer;
% set(t, 'Name', 'test', 'ExecutionMode', 'fixedRate', 'Period', 1, ...
%     'StartFcn', @start_callbck, 'TimerFcn', cbk, 'TasksToExecute', 2);
% %             , 'StopFcn',stop_callbck, ...
% %                 'ErrorFcn', @err_callbck, 'TasksToExecute', 2, 'UserData', 1, 'StartDelay', 1);
% 
%     function start_callbck(obj,~)
%         disp('started')
%     end


end

