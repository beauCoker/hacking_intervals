rng(3922)

%% Parameters
q = 4;
k = 4;

file = 'Alate Adelges data - Manual.csv';

%% Data

% Real data
X_raw = csvread(file);

X = (X_raw - mean(X_raw))./std(X_raw);

p = size(X,2);

% All subsets
% https://www.mathworks.com/matlabcentral/answers/78669-all-possible-unique-permutations-of-a-binary-vector
c = [0 1];
cc = c(fullfact(2*ones(p,1)));
C = logical(cc(sum(cc,2) == q,:));

[n_subsets_max,~] = size(C);

% Allocate
D = nan(n_subsets_max,1);
V_con = nan(n_subsets_max,1);
V_diff = nan(n_subsets_max,1);

%% Precompute

% For Krzanowski
[U,Psi,~] = svd(X);
S = U * Psi;
S = S(:,1:k);
S2 = S'*S;
tr_S2 = trace(S2);

% For Guo et al.
Y = S./sqrt(sum(svd(S'*S))).*sqrt(50);
Y2 = Y'*Y;
tr_Y2 = trace(Y2);

%% Compute D for each possible subset of q variables

for i=1:n_subsets_max
    X_s = X(:, C(i,:));    
    
    [U_s,Psi_s,~] = svd(X_s);
    S_s = U_s * Psi_s;
    S_s = S_s(:,1:k);
    
    S_s2 = S_s' * S_s;
    SS_s = S'*S_s;
    
    [~,Sigma_SS_s,~] = svd(SS_s);
    
    % Krzanowski method. Eq 9 from Guo et al.
    D(i) = tr_S2 + trace(S_s2) - 2*trace(Sigma_SS_s);
    % D(i) = trace(S'*S + S_s'*S_s - 2*Sigma_YY_s) % Equivalent caculation
    
    % Guo et al. method
    Y_s = S_s./sqrt(sum(svd(S_s2))).*sqrt(50);
    Y_s2 = Y_s'*Y_s;
    YY_s = Y'*Y_s;
    
    V_con(i) = 2*sum(svd(YY_s));
    
    [~,Sigma_YY_s,~] = svd(YY_s);
    V_diff(i) = tr_Y2 + trace(Y_s2) - 2*trace(Sigma_YY_s);
    %V_diff(i) = trace(Y'*Y + Y_s'*Y_s - 2*Sigma_YY_s); % Equivalent caculation
end

