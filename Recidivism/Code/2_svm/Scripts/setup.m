%% Creates all of the datasets used for svm analysis

clear
close all

% Folders
folder_home = '../../../';
folder_in = [folder_home 'Data/2_preprocessed/'];
folder_out = [folder_home 'Data/3_setup_svm/'];

% Preprocessed data
file_in = [folder_in 'compas_matlab_bin.csv'];

% Add functions to search path
addpath('../Functions')


%% Parameters for all datasets

% data is the features for algorithm input
col_feat = {'age_screening','c_charge_degree_F','sex_Male', ...
    'age_18_20', 'age_21_22', 'age_23_25', 'age_26_45', 'age__45',...
    'juvenile_felonies__0', 'juvenile_misdemeanors__0', 'juvenile_crimes__0',...
    'priors_2_3', 'priors__0', 'priors__1', 'priors__3','two_year_recid'};

% id is the features for identifying/aggregating observations
col_id = {'id','race','decile_score','score_text','two_year_recid'};

% Value of 'id' for people to manually add to xnew
id_add = [4704, 2825, 4772, 10258, 8731, 9346, 3338];

%% Test dataset
clearvars -except file_in col_feat col_id id_add folder_out

[V_id,V,y,xnew_id,xnew,data_names,u_group]=f_setup(...
    file_in,... % file_in
    5,... % n_xnew
    [],...% id_train
    100,... % n_train
    0,... % train_all
    col_feat,... % col_feat
    col_id,... % col_id
    'race',... % col_group
    [],... % group_select
    id_add);% id_add

save([folder_out 'svm_input_bin_test.mat'],'V_id','V','y','xnew_id','xnew','data_names','u_group')

%% Divided by compas score
clearvars -except file_in col_feat col_id id_add folder_out

[V_id,V,y,xnew_id,xnew,data_names,u_group]=f_setup(...
    file_in,... % file_in
    10,... % n_xnew
    [],...% id_train
    1000,... % n_train
    0,... % train_all
    col_feat,... % col_feat
    col_id,... % col_id
    'decile_score',... % col_group
    [],... % group_select
    id_add);% id_add

% Record ids of training data (use for score3 and score8)
id_train_decile = table2array(V_id(:,1));

save([folder_out 'svm_input_bin_decile_score.mat'],'V_id','V','y','xnew_id','xnew','data_names','u_group')

%% Compas score 3 only

clearvars -except file_in col_feat col_id id_add folder_out id_train_decile

[V_id,V,y,xnew_id,xnew,data_names,u_group]=f_setup(...
    file_in,... % file_in
    [],... % n_xnew
    id_train_decile,...% id_train  <-- use the same training set as decile
    [],... % n_train
    [],... % train_all
    col_feat,... % col_feat
    col_id,... % col_id
    'decile_score',... % col_group
    3,... % group_select
    id_add);% id_add

save([folder_out 'svm_input_bin_decile_score3.mat'],'V_id','V','y','xnew_id','xnew','data_names','u_group')

%% Compas score 8 only
clearvars -except file_in col_feat col_id id_add folder_out id_train_decile 

[V_id,V,y,xnew_id,xnew,data_names,u_group]=f_setup(...
    file_in,... % file_in
    [],... % n_xnew
    id_train_decile,...% id_train <-- use the same training set as decile
    [],... % n_train
    [],... % train_all 
    col_feat,... % col_feat
    col_id,... % col_id
    'decile_score',... % col_group
    8,... % group_select
    id_add);% id_add

save([folder_out 'svm_input_bin_decile_score8.mat'],'V_id','V','y','xnew_id','xnew','data_names','u_group')

%% Divided by race
clearvars -except file_in col_feat col_id id_add folder_out

[V_id,V,y,xnew_id,xnew,data_names,u_group]=f_setup(...
    file_in,... % file_in
    20,... % n_xnew
    [],...% id_train
    1000,... % n_train
    0,... % train_all
    col_feat,... % col_feat
    col_id,... % col_id
    'race',... % col_group
    {'African-American','Caucasian','Hispanic','Asian'},... % group_select
    id_add);% id_add

save([folder_out 'svm_input_bin_race.mat'],'V_id','V','y','xnew_id','xnew','data_names','u_group')