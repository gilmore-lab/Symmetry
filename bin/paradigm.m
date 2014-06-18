function [t,kill_hdl,setOutput_hdl,exp,routine,debug_exec] = paradigm(client,plugin)

% UI entry
frame = simpleui();
waitfor(frame,'Visible','off'); % Wait for visibility to be off
s = getappdata(frame,'UserData'); % Get frame data
java.lang.System.gc();

if isempty(s)
    error('scan.m (scan): User Cancelled.')
end

exp.sid = s{1};
exp.run = s{2};
exp.interval = s{3};
exp.trig = s{4};
% exp.order = cellfun(@(y)(regexprep(y,',','')),s{3},'UniformOutput',false);

% ID and path set-up
client.set_defaults_value('id',exp.sid);
idpath = fullfile(client.get_defaults_value('output'),client.get_defaults_value('id'));
mkdir(idpath);

% Rules and logic
% Filenames
% pat = '1(?<group>\d{2,2})0(?<image>\d{2,2})[.](?<imagetype>\w+)';
pat = '1(?<group>\d{2,2})0(?<image>\d{2,2})';
re = @(y)regexp(y,pat,'names');
[img_names,files_n] = client.get_image_names;
meta = cellfun(re,img_names);
data = client.data;

% Metadata mapping
for i = 1:files_n
    [~,name] = fileparts(img_names{i});
    meta(i).name = name;
end
var_1 = '01';
var_n = unique({meta(:).group});var_n = var_n(~strcmp(var_n,var_1));

% Formatting output buffer
splitBy = {var_1,var_n{:}};
setOutput_hdl = @setOutput;

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

% Timing

% Task
% if task
%         fix_color = {uint8([255, 0, 0]),uint8([0, 255, 0])};
%         fix_radius = 5;
%         fix_line = 2;
%         fix_p_chg = .7;
%         fix_type = {'FillOval'};
%
% Pres to segments, response out to timer

% Initialize window
plugin.open;

% Register
inv = Invoke(client,plugin);
routine = {}; % push
for iter_index = 1:length(top_iter)
    
    % Multiple segment registration for iter_some_subvar
    data_index1 = datasample(var_i{1},iter_some_subvar(iter_index),'Replace',false); % R2011b
    for i = 1:length(data_index1)
        inv.register(segment(data{data_index1(i)}),meta(data_index1(i)));
        routine(end+1,:) = {meta(data_index1(i)).name,meta(data_index1(i)).group,meta(data_index1(i)).image};
        % Keep data structure
    end
    % Individual segment registration for top_iter
    data_index2 = var_i{top_iter(iter_index)}(1);
    var_i{top_iter(iter_index)}(1) = []; % pop
    inv.register(segment(data{data_index2}),meta(data_index2));
    routine(end+1,:) = {meta(data_index2).name,meta(data_index2).group,meta(data_index2).image};
end

kill_hdl = @kill;
debug_exec = @(obj,evt)inv.execute;

t = timer;
set(t, 'Name', client.get_defaults_value('id'),...
    'ExecutionMode', 'fixedRate', ...
    'Period', exp.interval, ...
    'StartFcn', @(obj,evt)inv.markonset, ...
    'TimerFcn', @(obj,evt)inv.execute, ...
    'StopFcn', {@inv.stopcbk, exp.interval}, ...
    'TasksToExecute', 2); % size(routine,1)

%    'ErrorFcn', @err_callbck,'UserData', 1, 'StartDelay', 1);

    function kill(t)
        stop(t)
        delete(t)
    end
        
    function setOutput(run)
        % Format: 
        % Set-up output stream buffers for each conditions
        % Set a recording callback based on paradigm
        if any(strcmp('writeBuffer',properties(client)))
            mkdir([idpath filesep run]);
            for group_i = 1:length(splitBy)
                client.setUpOutputStream([client.get_defaults_value('id') filesep run filesep splitBy{group_i}]);
            end

        else
            ME = client.missingParameter('writeBuffer');
            throw(ME);
        end
        
        if any(strcmp('header',properties(client)))
            client.header = splitBy;
        else
            ME = client.missingParameter('header');
            throw(ME);
        end
        
        if any(strcmp('writeCb',properties(client)))
            client.writeCb = @writeCb;
        else
            ME = client.missingParameter('writeCb');
            throw(ME);
        end
        
        function writeCb(splitByString,value)
            % Add to an output buffer
            javaMethodEDT('appendToBuffer',client.writeBuffer{strcmp(splitByString,client.header)},value);
        end
        
    end

end

