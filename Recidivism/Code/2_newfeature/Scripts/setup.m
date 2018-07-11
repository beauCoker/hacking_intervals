clear
close all

% Formats data for use in the sensitivity analysis

folder_home = '../../../';
folder_in = [folder_home 'Data/2_preprocessed/'];
folder_out = [folder_home 'Data/3_setup_newfeature/'];

%% Parameters
file = [folder_in 'compas_matlab_bin.csv'];

% data is the features for algorithm input
col_feat = {'age_screening','c_charge_degree_F','sex_Male', ...
    'age_18_20', 'age_21_22', 'age_23_25', 'age_26_45', 'age__45',...
    'juvenile_felonies__0', 'juvenile_misdemeanors__0', 'juvenile_crimes__0',...
    'priors_2_3', 'priors__0', 'priors__1', 'priors__3','two_year_recid'};

% id is the features for identifying/aggregating observations
col_id = {'id','race','decile_score','score_text','two_year_recid'};


%% Read data
% NOTE: THIS SCRIPT MAKES ASSUMPTIONS ABOUT HOW COLUMNS ARE ORDERED

T = readtable(file);

T_names = T.Properties.VariableNames;

% Column number for id and data
colnum_id = cellfun(@(c) find(strcmp(T_names,c)),col_id);
colnum_feat = cellfun(@(c) find(strcmp(T_names,c)),col_feat);

% Extract data
data = table2array(T(:,colnum_feat));
data_names = T_names(colnum_feat);

% Extract id
id = T(:,colnum_id);
id_names = T_names(colnum_id);


%% Save results
save([folder_out '/newfeature_input.mat'],'data','data_names','id','id_names')
