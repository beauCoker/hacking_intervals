%% Calculates hacking intervals on given dataset

preamble_main

%% Compas score 3 only
clearvars -except C theta_factor folder_in folder_out

out=f_recid(...
    C,... % C
    theta_factor,... % theta_factor
    [folder_in 'svm_input_bin_decile_score3.mat']); % file_in

writetable(out,[folder_out 'svm_output_bin_decile_score3.csv'])