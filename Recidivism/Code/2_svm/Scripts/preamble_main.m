%% Each 'main_[type]' script calls this first

clear
close all

%% Locations of stuff

% Folders
folder_home = '../../../';
folder_in = [folder_home 'Data/3_setup_svm/'];
folder_out = [folder_home 'Results/svm/Tables/'];

% Add functions to search path
addpath('../Functions')

%% Parameters for all datasets
C = 1;
theta_factor = 1.05;