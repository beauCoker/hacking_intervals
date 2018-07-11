clear
close all

% Formats data for use in the sensitivity analysis

folder_home = '../../../';
folder_in = [folder_home 'Data/2_preprocessed/'];
folder_out = [folder_home 'Data/3_setup_newfeature/'];

%% Parameters
file = [folder_in 'compas_matlab_bin.csv'];

% data is the features for algorithm input
col_data = {'sex_Male', 'age_screening','c_days_from_compas',...
    'juv_fel_count', 'juv_misd_count', 'juv_other_count',...
    'priors_count', 'c_charge_degree_F', 'is_recid'};

% id is the features for identifying/aggregating observations
col_id = {'id','race','decile_score','score_text','is_recid'};


%% Read data
% NOTE: THIS SCRIPT MAKES ASSUMPTIONS ABOUT HOW COLUMNS ARE ORDERED

T = readtable(file);

T_names = T.Properties.VariableNames;

% Column number for id and data
colnum_id = cellfun(@(c) find(strcmp(T_names,c)),col_id);
colnum_data = cellfun(@(c) find(strcmp(T_names,c)),col_data);

% Extract data
data = table2array(T(:,colnum_data));
data_names = T_names(colnum_data);

% Extract id
id = T(:,colnum_id);
id_names = T_names(colnum_id);


%% Save results
save([folder_out '/newfeature_input_old.mat'],'data','data_names','id','id_names')
