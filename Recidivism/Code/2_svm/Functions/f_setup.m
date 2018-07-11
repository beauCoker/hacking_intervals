function [V_id,V,y,xnew_id,xnew,data_names,u_group]=f_setup(...
    file_in,...
    n_xnew,...
    id_train,...
    n_train,...
    train_all,...
    col_feat,...
    col_id,...
    col_group,...
    group_select,...
    id_add)
    
%% Formats data for use in the SVM analysis
% Randomly divides recidivism data into data for loss constraint (training data) 
% and data for hacking interval calculation. 
% The latter is broken up into groups based on a specified variable (e.g., race).
%
%Input:
%   file_in: file path of input data (csv)
%   file_out: file to save
%   n_xnew: Number of randomly selected observations in each group or []
%       for all groups
%   id_train: ids of training data. Set to [] to randomly select.
%   n_train: Number of randomly selected observations in training data.
%   train_all: Randomly select training from all data or data not in groups
%   col_feat: Features to select (names)
%   col_id: Identification variables (e.g., race) (names)
%   col_group: Column name of group on which to divide (e.g., race)
%   group_select: groups to select (must be appropriate variable type) or
%       [] for all groups
%   id_add: id of observations to require are in xnew
%Output (saved as .mat file):
%   n_group: Number of groups
%   u_group: Name of each group
%   V: Loss constraint features
%   y: Loss constraint labels
%   xnew: 1xn_group cell with features and label for each group
%   data_names: feature names
%   xnew_id: 1xn_group cell with identification variables for each group
%   V_id: Loss constraint identification variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Read data
% NOTE: THIS SCRIPT MAKES ASSUMPTIONS ABOUT HOW COLUMNS ARE ORDERED

T = readtable(file_in);

T_names = T.Properties.VariableNames;

% Column number for id and data
colnum_id = cellfun(@(c) find(strcmp(T_names,c)),col_id);
colnum_data = cellfun(@(c) find(strcmp(T_names,c)),col_feat);

% Extract data
data = table2array(T(:,colnum_data));
data_names = T_names(colnum_data);

% Extract id columns
id = T(:,colnum_id);
id_names = T_names(colnum_id);

% Extract column on which we'll group this data
colnum_group = find(strcmp(col_group, T_names));
[n, ~] = size(data);

% Find row numbers of observations to manually add
rowid_add = arrayfun(@(x) find(x==T.id),id_add);

%% Data for hacking intervals (xnew)
rng(492)

group = table2array(T(:,colnum_group));

if isempty(group_select)
    % Use all the groups
    u_group = unique(group);
else
    % Use only selected groups
    u_group = group_select;
end
n_group = length(u_group);

% Allocate space
xnew = cell(1,n_group);
xnew_id = cell(1,n_group);
rowid_xnew_group = cell(1,n_group);

for i=1:n_group
    
    % Get rows numbers from this group
    if isnumeric(group)
        rowid_group = find(group==u_group(i));
    elseif iscellstr(group)
        rowid_group = find(strcmp(group,u_group(i)));
    end
    
    % Allocate space for total number of observations to select for this group
    if isempty(n_xnew)
        % All observations in this group
        n_xnew_group = length(rowid_group);
    else
        % Only n_xnew observations (or all if less than n_xnew)
        n_xnew_group = min(n_xnew,length(rowid_group));
    end
    rowid_xnew_group{i} = nan(1,n_xnew_group);
    
    % Add manually selected observations
    rowid_add_group = intersect(rowid_add, rowid_group);
    n_add_group = length(rowid_add_group);
    if n_add_group > 0
        if n_add_group <= n_xnew_group
            rowid_xnew_group{i}(1:n_add_group) = rowid_add_group;
        else
            error('Too many observations to add')
        end
    end
    
    % Randomly select the rest
    n_sample = n_xnew_group - n_add_group;
    if n_sample > 0
        rowid_xnew_group{i}((n_add_group+1):(n_add_group+n_sample)) = randsample(setdiff(rowid_group, rowid_add_group), n_sample);
    end
    
    % Extract data
    xnew{i} = data(rowid_xnew_group{i},:);
    xnew_id{i} = id(rowid_xnew_group{i},:);
    
end

%% Data for loss constraint
if isempty(id_train)
    
    % If training ids are not specified, randomly select the training data
    if train_all == 1
        % From all obsverations
        rowid_train = randsample(1:n, n_train);
    else
        % From only those not in groups
        rowid_train = randsample(setdiff((1:n)',cell2mat(rowid_xnew_group)), n_train);
    end    
else
    
    % ids specified, so find corresponding rowid
    [~,~,rowid_train] = intersect(id_train,T.id, 'stable');
    n_train = length(id_train);
end

% Extract data
V = data(rowid_train,1:end-1);
y = data(rowid_train,end);
y(y==0)= -1;

V_id = id(rowid_train,1:end-1);

%% Scale data
% Calculate means and std devs on training data if required
m = mean(V,1); 
s = std(V,1,1); 

% Replace zero standard deviation with 1
if any(s==0)
    s(s==0) = 1;
    warning('Some training variables have zero standard deviaton')
end

V = (V - repmat(m,n_train,1))./repmat(s,n_train,1);
xnew = cellfun(@(x) [(x(:,1:end-1) - repmat(m,size(xnew,1),1))./repmat(s,size(xnew,1),1) x(:,end)], xnew, 'UniformOutput',0);

% Check out counts by group
figure
histogram(categorical(group))
title('Group counts')

