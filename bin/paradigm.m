function [t,kill_hdl,setOutput_hdl,exp,registerRoutine_hdl,debug_exec] = paradigm(client,plugin)

if ~client.get_defaults_value('debug')
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
    exp.tr = s{4};
    exp.trig = s{5};
    % exp.order = cellfun(@(y)(regexprep(y,',','')),s{3},'UniformOutput',false);
    
    % ID and path set-up
    client.set_defaults_value('id',exp.sid);
    idpath = fullfile(client.get_defaults_value('output'),client.get_defaults_value('id'));
    mkdir(idpath);
else
    client.set_defaults_value('id',['debug_' datestr(now,30)]);
    idpath = fullfile(client.get_defaults_value('output'),client.get_defaults_value('id'));
    mkdir(idpath);
    exp.interval = 1.2;
end

% Rules and logic
% Filenames
% pat = '1(?<group>\d{2,2})0(?<image>\d{2,2})[.](?<imagetype>\w+)';
pat = '1(?<group>\d{2,2})0(?<image>\d{2,2})';
re = @(y)regexp(y,pat,'names');
[img_names,files_n] = client.get_image_names;
meta = cellfun(re,img_names);
data = client.data;

% Metadata mapping
group_naming = {'01','p1','intact';...
    '02','p2','intact';...
    '03','pm','intact';...
    '04','pg','intact';...
    '06','pmm','intact';...
    '19','p2','scrambled';...
    '20','pm','scrambled';...
    '21','pg','scrambled';...
    '23','pmm','scrambled';};

for i = 1:files_n
    [~,name] = fileparts(img_names{i});
    meta(i).name = name;
    meta(i).cname = group_naming{strcmp(meta(i).group,group_naming(:,1)),2};
    meta(i).phase = group_naming{strcmp(meta(i).group,group_naming(:,1)),3};
end
var_1 = '01';
var_n = unique({meta(:).group});var_n = var_n(~strcmp(var_n,var_1));

% Formatting output buffer
splitBy = {var_1,var_n{:}};
setOutput_hdl = @setOutput;

% Subdivisions, image index, and validation
var_i = {}; % push
for i = 0:size(var_n,2)
    if i
        var_i{end+1} = find(strcmp(var_n{i},{meta(:).group}));
    else
        var_i{end+1} = find(strcmp(var_1,{meta(:).group}));
    end
    assert(length(unique({meta(var_i{end}).image})) == length({meta(var_i{end}).image}),'Image duplicates found!');
end
set_n = unique(cellfun(@length,var_i));
assert(length(set_n)==1,'Inconsistent image sets found!')

% Split into 2 conditions (1:1 relationship), name
group_div = 2;
grouping1 = var_n(1:length(var_n)/group_div);
grouping2 = var_n((1+length(var_n)/group_div):length(var_n));
assert(length(grouping1) == length(grouping2),'Inconsistent image groupings between "scrambled" and "intact" found!')

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

if ~client.get_defaults_value('debug')
    % Initialize window
    plugin.open;
end

inv = Invoke(client,plugin);
registerRoutine_hdl = @registerRoutine;

% % Register
% routine = {}; % push
% for iter_index = 1:length(top_iter)
%     
%     % Multiple segment registration for iter_some_subvar
%     data_index1 = datasample(var_i{1},iter_some_subvar(iter_index),'Replace',false); % R2011b
%     for i = 1:length(data_index1)
%         inv.register(segment(data{data_index1(i)}),meta(data_index1(i)));
%         routine(end+1,:) = {meta(data_index1(i)).name,meta(data_index1(i)).group,meta(data_index1(i)).image};
%         % Keep data structure
%     end
%     % Individual segment registration for top_iter
%     data_index2 = var_i{top_iter(iter_index)}(1);
%     var_i{top_iter(iter_index)}(1) = []; % pop
%     inv.register(segment(data{data_index2}),meta(data_index2));
%     routine(end+1,:) = {meta(data_index2).name,meta(data_index2).group,meta(data_index2).image};
% end

kill_hdl = @kill;
debug_exec = @(obj,evt)inv.execute;

t = timer;
set(t, 'Name', client.get_defaults_value('id'),...
    'ExecutionMode', 'fixedRate', ...
    'Period', exp.interval, ...
    'StartFcn', @(obj,evt)inv.markonset, ...
    'TimerFcn', @(obj,evt)inv.execute, ...
    'StopFcn', {@inv.stopcbk, exp.interval});

%    'ErrorFcn', @err_callbck,'UserData', 1, 'StartDelay', 1);

    function kill(t)
        stop(t)
        delete(t)
    end

    function [routine] = registerRoutine()
        
        % "Optseq" e-mail, Peter Jes Kohler, pjkohler@stanford.edu
        % Deprecate in future release
        tempIdx1 = repmat(1:length(grouping1),set_n);
        condOrder = tempIdx1(randperm(length(tempIdx1)));
        reps = 1:3;
        tempIdx2 = repmat(reps,1,round(length(condOrder)/(length(reps))));
        jitterOrder = tempIdx2(randperm(length(tempIdx2)));
        jitterOrder = jitterOrder(logical(condOrder)); % Idempotent
        % Deprecate in future release
        
        top_iter = condOrder; % Grouping 1
        iter_some_subvar = jitterOrder;

        inv.reset();
        routine = {}; % push

        random_within_var = true; % Missing business rule, assuming random
        if random_within_var
            index = cellfun(@(y)(Shuffle(y)),var_i,'UniformOutput',false);
        else
            index = var_i;
        end
        
        for iter_index = 1:length(top_iter)
            
            % Multiple segment registration for iter_some_subvar
            data_index1 = datasample(index{1},iter_some_subvar(iter_index),'Replace',false); % R2011b
            for i = 1:length(data_index1)
                inv.register(segment(data{data_index1(i)}),meta(data_index1(i)));
                routine(end+1,:) = {meta(data_index1(i)).cname,meta(data_index1(i)).image,meta(data_index1(i)).name,meta(data_index1(i)).phase};
                % Keep data structure
            end
            % Individual segment registration for top_iter, grouping2 +
            % grouping1
            data_index2 = index{top_iter(iter_index)+1}(1);
            data_index3 = index{top_iter(iter_index)+1+(length(var_n)/group_div)}(1);
            index{top_iter(iter_index)+1}(1) = []; % pop
            index{top_iter(iter_index)+1+(length(var_n)/group_div)}(1); % pop
            % grouping2
            inv.register(segment(data{data_index3}),meta(data_index3));
            routine(end+1,:) = {meta(data_index3).cname,meta(data_index3).image,meta(data_index3).name,meta(data_index3).phase};
            % grouping1
            inv.register(segment(data{data_index2}),meta(data_index2));
            routine(end+1,:) = {meta(data_index2).cname,meta(data_index2).image,meta(data_index2).name,meta(data_index2).phase};
        end
        
        set(t,'TasksToExecute', size(routine,1));
    end

    function setOutput(run)
        % Format: 
        % Set-up output stream buffers for each conditions
        % Set a recording callback based on paradigm
        if any(strcmp('writeBuffer',properties(client)))
            mkdir([idpath filesep run]);
            for group_i = 1:length(splitBy)
                client.setUpOutputStream([client.get_defaults_value('id') filesep run filesep splitBy{group_i} '_' group_naming{strcmp(splitBy{group_i},group_naming(:,1)),2}]);
            end

        else
            ME = client.missingParameter('writeBuffer');
            throw(ME);
        end
        
        if any(strcmp('groups',properties(client)))
            client.groups = splitBy;
        else
            ME = client.missingParameter('groups');
            throw(ME);
        end
        
        if any(strcmp('writeCb',properties(client)))
            client.writeCb = @writeCb;
        else
            ME = client.missingParameter('writeCb');
            throw(ME);
        end
        
        if any(strcmp('mainWriteCb',properties(client)))
            if any(strcmp('csvFid',properties(client)))
                csvPath = [idpath filesep run filesep client.get_defaults_value('generaloutputname') '.' client.get_defaults_value('generaloutputtype')];
                csvFid = fopen(csvPath,'w');
                if csvFid~=-1
                    client.csvFid = csvFid;
                else
                    ME = client.errorFileOpen(csvPath);
                    throw(ME);
                end
            else
                ME = client.missingParameter('csvFid');
                throw(ME);
            end
            client.mainWriteCb = @mainWriteCb;
        else
            ME = client.missingParameter('mainWriteCb');
            throw(ME);
        end

        function writeCb(splitByString,value)
            % Add to an output buffer
            javaMethodEDT('appendToBuffer',client.writeBuffer{strcmp(splitByString,client.groups)},value);
        end
        
        function mainWriteCb(cname,image,group,phase,onset)
            fprintf(client.csvFid,'%s,%s,%s,%s,%6.4f\n',cname,image,group,phase,onset);
        end
        
    end

end

